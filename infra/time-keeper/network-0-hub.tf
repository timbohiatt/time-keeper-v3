


module "vpc-hub" {
  source     = "./modules/net-vpc"
  project_id = google_project.project.project_id
  name       = "${var.prefix}-${var.demo_name}-${var.env}-gbl-hub"
  subnets = [
    {
      ip_cidr_range = var.ip_ranges.hub
      name          = "${var.prefix}-${var.demo_name}-${var.env}-${var.region}-hub-sub"
      region        = var.region
    }
  ]
}

module "nat-hub" {
  for_each = {
    for k, v in local.gke_clusters : k => v
    if v.enabled
  }
  source         = "./modules/net-cloudnat"
  project_id     = google_project.project.project_id
  region         = try(each.value.region, null)
  name           = "${var.prefix}-${var.demo_name}-${var.env}-nat-gw-${each.value.region}"
  router_name    = "${var.prefix}-${var.demo_name}-${var.env}-nat-rtr-${each.value.region}"
  router_network = module.vpc-hub.self_link
}
/*
module "nat-hub" {
  source         = "./modules/net-cloudnat"
  project_id     = google_project.project.project_id
  region         = var.region
  name           = "${var.prefix}-${var.demo_name}-${var.env}-${var.region}-hub-nat"
  router_name    = "${var.prefix}-${var.demo_name}-${var.env}-${var.region}-hub-rtr"
  router_network = module.vpc-hub.self_link
}*/

module "vpc-hub-firewall" {
  source     = "./modules/net-vpc-firewall"
  project_id = google_project.project.project_id
  network    = module.vpc-hub.name
  default_rules_config = {
    admin_ranges = values(var.ip_ranges)
  }
}