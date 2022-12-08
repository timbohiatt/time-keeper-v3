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

module "gke_region" {
  source = "./modules/gke_region"
  for_each = {
    for k, v in local.gke_clusters : k => v
    if v.enabled
  }
  defaults                            = local.gke_defaults
  project_id                          = google_project.project.project_id
  prefix                              = "${var.prefix}-${var.demo_name}-${var.env}"
  cluster_name                        = try(each.value.cluster_name, null)
  region                              = try(each.value.region, null)
  vpc_network_self_link               = module.vpc-spoke-1.self_link
  subnet_config                       = try(each.value.subnet_config, null)
  private_cluster_config              = try(each.value.private_cluster_config, null)
  master_global_access_config_enabled = try(each.value.master_global_access_config_enabled, null)
  service_account                     = try(each.value.service_account, google_service_account.gke_service_account.email)
  logging_service                     = try(each.value.logging_service, null)
  monitoring_service                  = try(each.value.monitoring_service, null)
  enable_cost_management_config       = try(each.value.enable_cost_management_config, null)
  min_master_version                  = try(each.value.min_master_version, null)
  master_authorized_networks_cidr_blocks = coalesce([{
    cidr_block   = google_compute_subnetwork.subnet-jump-vm.ip_cidr_range
    display_name = "jump-vm"
  }, ], try(each.value.master_authorized_networks_cidr_blocks, []))
  //depends_on = [google_compute_firewall.egress-allow-gke-node, google_compute_firewall.ingress-allow-gke-node]
}
 