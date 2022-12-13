/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */




module "vpc-hub" {
  source     = "./modules/net-vpc"
  project_id = google_project.project.project_id
  name       = "${var.prefix}-${var.demo_name}-${var.env}-gbl-hub"
  delete_default_routes_on_create = true
  /*subnets = [
    {
      ip_cidr_range = var.ip_ranges.hub
      name          = "${var.prefix}-${var.demo_name}-${var.env}-${var.region}-hub-sub"
      region        = var.region
    }
  ]*/
}
/*
module "nat-hub" {
  for_each = {
    for k, v in local.gke_clusters : k => v
    if v.enabled
  }
  source         = "./modules/net-cloudnat"
  project_id     = google_project.project.project_id
  region         = try(each.value.region, null)
  name           = "${var.prefix}-${var.demo_name}-${var.env}-hub-nat-gw-${each.value.region}"
  router_name    = "${var.prefix}-${var.demo_name}-${var.env}-hub-nat-rtr-${each.value.region}"
  router_network = module.vpc-hub.self_link
}*/
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