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


// Create the firewall rules to allow nodes to communicate with the control plane
resource "google_compute_firewall" "egress-allow-gke-node" {
  project = var.project_id
  network = var.vpc_network_self_link

  //name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-allow-egress-${random_id.postfix.hex}"
  //name = "${local.cluster_name}-egress"
  name = "${local.cluster_name}-egress-${random_integer.np_ext_salt.result}"

  priority  = "200"
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "9443", "10250", "15017", "6443"]
  }

  destination_ranges = [local.pcc_master_ipv4_cidr_block]
  target_service_accounts = [
    local.service_account_internal,
    local.service_account_egress,
    local.service_account
  ]
}
 
resource "google_compute_firewall" "ingress-allow-gke-node" {
  project = var.project_id
  network = var.vpc_network_self_link

  //name = "${var.prefix}-${var.demo_name}-${var.env}-gke-node-allow-ingress-${random_id.postfix.hex}"
  name = "${local.cluster_name}-ingress-${random_integer.np_ext_salt.result}"

  priority  = "200"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "9443", "10250", "15017", "6443"]
  }

  source_ranges = [local.pcc_master_ipv4_cidr_block]
  source_service_accounts = [
    local.service_account_internal,
    local.service_account_egress
  ]
}