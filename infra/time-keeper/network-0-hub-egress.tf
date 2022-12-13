locals {
  SquidServiceAccountIAMRoles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
  squid_address = (
    var.mig
    ? module.squid-ilb.0.forwarding_rule_address
    : module.squid-vm.internal_ip
  )
}

variable "allowed_domains" {
  description = "List of domains allowed by the squid proxy."
  type        = list(string)
  default = [
    ".google.com",
    ".github.com"
  ]
}

variable "cidrs" {
  description = "CIDR ranges for subnets."
  type        = map(string)
  default = {
    apps  = "10.128.16.0/21"
    proxy = "10.0.1.0/28"
    jump  = "10.128.40.0/21"
  }
}

variable "mig" {
  description = "Enables the creation of an autoscaling managed instance group of squid instances."
  type        = bool
  default     = true
}

variable "nat_logging" {
  description = "Enables Cloud NAT logging if not null, value is one of 'ERRORS_ONLY', 'TRANSLATIONS_ONLY', 'ALL'."
  type        = string
  default     = "ALL"
}



resource "google_compute_subnetwork" "hub-subnet-egress" {
  project                  = google_project.project.project_id
  name                     = "${var.prefix}-${var.demo_name}-${var.env}-hub-egress-${var.region}"
  ip_cidr_range            = "10.128.16.0/21"
  network                  = module.vpc-hub.self_link
  region                   = var.region
  private_ip_google_access = true
}

module "firewall" {
  source     = "./modules/net-vpc-firewall-squid"
  project_id = google_project.project.project_id
  network    = module.vpc-hub.name
  ingress_rules = {
    allow-ingress-squid = {
      description = "Allow squid ingress traffic"
      source_ranges = [
        var.cidrs.apps, "35.191.0.0/16", "130.211.0.0/22", "0.0.0.0/0"
      ]
      targets              = [google_service_account.service-account-squid.email]
      use_service_accounts = true
      rules = [{
        protocol = "tcp"
        ports    = [3128]
      }]
    }
  }
}

module "nat" {
  source                = "./modules/net-cloudnat"
  project_id            = google_project.project.project_id
  region                = var.region
  name                  = "${var.prefix}-${var.demo_name}-${var.env}-hub-nat-gw-${var.region}"
  router_network        = module.vpc-hub.name
  config_source_subnets = "LIST_OF_SUBNETWORKS"
  # 64512/11 = 5864 . 11 is the number of usable IPs in the proxy subnet
  config_min_ports_per_vm = 5864
  subnetworks = [
    {
      self_link            = google_compute_subnetwork.hub-subnet-egress.self_link
      config_source_ranges = ["ALL_IP_RANGES"]
      secondary_ranges     = null
    }
  ]
  logging_filter = var.nat_logging
}

module "private-dns" {
  source          = "./modules/dns"
  project_id      = google_project.project.project_id
  type            = "private"
  name            = "${var.prefix}-${var.demo_name}-${var.env}-squid-internal"
  domain          = "internal."
  client_networks = [module.vpc-hub.self_link]
  recordsets = {
    "A squid"     = { ttl = 60, records = [local.squid_address] }
    "CNAME proxy" = { ttl = 3600, records = ["squid.internal."] }
  }
}

###############################################################################
#                               Squid resources                               #
###############################################################################


resource "google_service_account" "service-account-squid" {
  project = google_project.project.project_id
  #account_id   = "${var.prefix}-${var.demo_name}-${var.env}-svc-squid"
  #display_name = "${var.prefix}-${var.demo_name}-${var.env}-svc-squid"
  account_id   = "lol-svc-squid"
  display_name = "lol-svc-squid"
}

resource "google_project_iam_member" "squid_service_account" {
  count   = length(local.SquidServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.SquidServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${google_service_account.service-account-squid.email}"
}



# module "service-account-squid" {
#   source     = "./modules/iam-service-account"
#   project_id = google_project.project.project_id
#   name       = "${var.prefix}-${var.demo_name}-${var.env}-svc-squid"
#   iam_project_roles = {
#     (google_project.project.project_id) = [
#       "roles/logging.logWriter",
#       "roles/monitoring.metricWriter",
#     ]
#   }
# }

module "cos-squid" {
  source  = "./modules/cloud-config-container/squid"
  allow   = var.allowed_domains
  clients = [var.cidrs.apps, var.cidrs.jump, "0.0.0.0/0"]
}

module "squid-vm" {
  source          = "./modules/compute-vm"
  project_id      = google_project.project.project_id
  zone            = "${var.region}-b"
  name            = "${var.prefix}-${var.demo_name}-${var.env}-squid-vm"
  instance_type   = "e2-medium"
  create_template = var.mig
  network_interfaces = [{
    network    = module.vpc-hub.self_link
    subnetwork = google_compute_subnetwork.hub-subnet-egress.self_link
  }]
  boot_disk = {
    image = "cos-cloud/cos-stable"
  }
  service_account        = google_service_account.service-account-squid.email
  service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  metadata = {
    user-data              = module.cos-squid.cloud_config,
    google-logging-enabled = true,
    enable-oslogin         = true
  }
}

resource "google_compute_firewall" "jump-ssh-allow-hub" {
  project   = google_project.project.project_id
  network   = module.vpc-hub.self_link
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
  name          = "${var.prefix}-${var.demo_name}-${var.env}-hub-iap"
  priority      = "100"
}

module "squid-mig" {
  count             = var.mig ? 1 : 0
  source            = "./modules/compute-mig"
  project_id        = google_project.project.project_id
  location          = "${var.region}-b"
  name              = "${var.prefix}-${var.demo_name}-${var.env}-squid-mig"
  instance_template = module.squid-vm.template.self_link
  target_size       = 1
  auto_healing_policies = {
    initial_delay_sec = 60
  }
  autoscaler_config = {
    max_replicas    = 10
    min_replicas    = 1
    cooldown_period = 30
    scaling_signals = {
      cpu_utilization = {
        target = 0.65
      }
    }
  }
  health_check_config = {
    enable_logging = true
    tcp = {
      port = 3128
    }
  }
}

module "squid-ilb" {
  count         = var.mig ? 1 : 0
  source        = "./modules/net-ilb"
  project_id    = google_project.project.project_id
  region        = var.region
  name          = "${var.prefix}-${var.demo_name}-${var.env}-squid-ilb"
  ports         = [3128]
  service_label = "squid-ilb"
  vpc_config = {
    network    = module.vpc-hub.self_link
    subnetwork = google_compute_subnetwork.hub-subnet-egress.self_link
  }
  backends = [{
    group = module.squid-mig.0.group_manager.instance_group
  }]
  health_check_config = {
    enable_logging = true
    tcp = {
      port = 3128
    }
  }
}

###############################################################################
#                               Service project                               #
###############################################################################

# module "folder-apps" {
#   source = "./modules/folder"
#   parent = var.root_node
#   name   = "apps"
#   org_policies = {
#     # prevent VMs with public IPs in the apps folder
#     "constraints/compute.vmExternalIpAccess" = {
#       deny = { all = true }
#     }
#   }
# }

# module "project-app" {
#   source          = "./modules/project"
#   billing_account = var.billing_account
#   name            = "app1"
#   parent          = module.folder-apps.id
#   prefix          = var.prefix
#   services        = ["compute.googleapis.com"]
#   shared_vpc_service_config = {
#     host_project = module.project-host.project_id
#     service_identity_iam = {
#       "roles/compute.networkUser" = ["cloudservices"]
#     }
#   }
# }

/*module "test-vm" {
  source        = "./modules/compute-vm"
  project_id    = google_project.project.project_id
  zone          = "${var.region}-b"
  name          = "test-vm-tim"
  instance_type = "e2-micro"
  tags          = ["ssh"]
  network_interfaces = [{
    network    = module.vpc-hub.self_link
    subnetwork = google_compute_subnetwork.hub-subnet-egress.self_link
    nat        = false
    addresses  = null
  }]
  boot_disk = {
    image = "debian-cloud/debian-10"
    type  = "pd-standard"
    size  = 10
  }
  service_account_create = true
}*/


# // Route Spoke Internet Traffic to Hub ILB for SQUID Proxy
# resource "google_compute_route" "route-ilb" {
#   project = google_project.project.project_id
#   name         = "route-egress-ilb-to-hub-nat"
#   dest_range   = "0.0.0.0/0"
#   network      = module.vpc-spoke-1.name
#   next_hop_ilb = module.squid-ilb[0].forwarding_rule_id
#   //next_hop_ilb = google_compute_forwarding_rule.google_compute_forwarding_rule.id
#   priority     = 0
#   description = "Default route to the Internet via SQUID."
# }
