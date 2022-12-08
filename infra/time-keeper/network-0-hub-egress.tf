resource "google_compute_subnetwork" "hub-subnet-egress" {
  name                     = "${var.prefix}-${var.demo_name}-${var.env}-hub-egress-${var.region}"
  ip_cidr_range            = "10.128.16.0/21"
  network                  = module.vpc-hub.self_link
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_health_check" "autohealing" {
  project = google_project.project.project_id
  name                = "${var.prefix}-${var.demo_name}-${var.env}-autohealing-hc"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/healthz"
    port         = "8080"
  }
}

resource "google_compute_instance_group_manager" "instance_group_manager" {
  name               = "${var.prefix}-${var.demo_name}-${var.env}-mig-egress-squid"
  
  version {
    instance_template  = google_compute_instance_template.egress-squid.id
  }
  base_instance_name = "${var.prefix}-${var.demo_name}-${var.env}-vm-egress-squid"
  zone               = "europe-west6-a"
  target_size        = "3"
}

resource "google_service_account" "sc-mig-egress-squid" {
  project = google_project.project.project_id
  account_id   = "${var.prefix}-${var.demo_name}-${var.env}-sc-mig-egress-squid"
  display_name = "Service Account"
}

resource "google_compute_instance_template" "egress-squid" {
  name_prefix  = "${var.prefix}-${var.demo_name}-${var.env}-mig-egress-squid"
  description = "Egress Squid Proxy in Hub Network in ${var.region}."
  tags = ["${var.prefix}-${var.demo_name}-${var.env}-egress-squid"]
  labels = {
    environment = "${var.env}"
    demo = "${var.demo_name}"
    traffic = "egress"
    type = "squid"
    network = "hub"
  }

  instance_description = "Egress Squid Proxy in Hub Network in ${var.region}"
  machine_type         = "n2-standard-8"
  can_ip_forward       = true

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image      = "debian-cloud/debian-11"
    auto_delete       = true
    boot              = true
    // backup the disk every day
    resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  // Use an existing disk resource
  disk {
    // Instance Templates reference disks by name, not self link
    source      = google_compute_disk.egress-squid.name
    auto_delete = false
    boot        = false
  }

  network_interface {
    //network = module.vpc-hub.self_link
    subnetwork    = google_compute_subnetwork.hub-subnet-egress.name
  }


  service_account {
    email  = google_service_account.sc-mig-egress-squid.email
    scopes = ["cloud-platform"]
  }
}

data "google_compute_image" "egress-squid" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_disk" "egress-squid" {
  project = google_project.project.project_id
  name  = "${var.prefix}-${var.demo_name}-${var.env}-egress-squid-disk"
  image = data.google_compute_image.egress-squid.self_link
  size  = 50
  type  = "pd-ssd"
  zone  = "europe-west6-a"
}

resource "google_compute_resource_policy" "daily_backup" {
  project = google_project.project.project_id
  name   = "${var.prefix}-${var.demo_name}-${var.env}-egress-squid-bkp-daily"
  region = "europe-west6"
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
  }
}



# forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "${var.prefix}-${var.demo_name}-${var.env}-egress-l4-ilb-forwarding-rule"
  backend_service       = google_compute_region_backend_service.egress-squid.id
  region                = "europe-west6"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  network               = module.vpc-hub.self_link
  subnetwork            = google_compute_subnetwork.hub-subnet-egress.id
}

# backend service
resource "google_compute_region_backend_service" "egress-squid" {
  name                  = "${var.prefix}-${var.demo_name}-${var.env}-egress-l4-ilb-backend-subnet"
  region                = "europe-west6"
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.autohealing.id]
  backend {
    group          = google_compute_instance_group_manager.instance_group_manager.instance_group
    balancing_mode = "CONNECTION"
  }
}



/*resource "google_compute_firewall" "vm-ssh" {
  name    = "${var.network_name}-ssh"
  network = module.vpc-hub.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.network_name}-ssh"]
}*/

// Since we aren't using the NAT on the test VM, add separate firewall rule for the squid proxy.
/*resource "google_compute_firewall" "nat-squid" {
  name    = "${var.prefix}-${var.demo_name}-${var.env}-squid"
  network = google_compute_subnetwork.hub-subnet-egress.name

  allow {
    protocol = "tcp"
    ports    = ["3128"]
  }

  source_tags = ["${var.network_name}-squid"]
  target_tags = ["inst-${module.nat.routing_tag_zonal}"]
}*/

/*
output "nat-host" {
  value = "${module.nat.instance}"
}

output "nat-ip" {
  value = "${module.nat.external_ip}"
}

output "vm-host" {
  value = "${google_compute_instance.vm.self_link}"
}*/
