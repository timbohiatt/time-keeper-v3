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

module "vpc-spoke-1" {
  source     = "./modules/net-vpc"
  project_id = google_project.project.project_id
  name       = "${var.prefix}-${var.demo_name}-${var.env}-gbl-spk-mytimekeeper"
  /*subnets = [
    {
      ip_cidr_range = var.ip_ranges.spoke-1
      name          = "${var.prefix}-${var.demo_name}-${var.env}-${var.region}-spk-1-sub-mytimekeeper"
      region        = var.region
      secondary_ip_ranges = {
        pods     = var.ip_secondary_ranges.spoke-1-pods
        services = var.ip_secondary_ranges.spoke-1-services
      }
    }
  ]*/
}

module "vpc-spoke-1-firewall" {
  source     = "./modules/net-vpc-firewall"
  project_id = google_project.project.project_id
  network    = module.vpc-spoke-1.name
  default_rules_config = {
    admin_ranges = values(var.ip_ranges)
  }
}

module "hub-to-spoke-1-peering" {
  source                     = "./modules/net-vpc-peering"
  local_network              = module.vpc-hub.self_link
  peer_network               = module.vpc-spoke-1.self_link
  export_local_custom_routes = true
  export_peer_custom_routes  = false
  //depends_on                 = [module.hub-to-spoke-1-peering]
}


module "nat-spoke" {
  for_each = {
    for k, v in local.gke_clusters : k => v
    if v.enabled
  }
  source         = "./modules/net-cloudnat"
  project_id     = google_project.project.project_id
  region         = try(each.value.region, null)
  name           = "${var.prefix}-${var.demo_name}-${var.env}-spoke-nat-gw-${each.value.region}"
  router_name    = "${var.prefix}-${var.demo_name}-${var.env}-spoke-nat-rtr-${each.value.region}"
  router_network = module.vpc-spoke-1.self_link
}