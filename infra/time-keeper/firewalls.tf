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
resource "google_compute_firewall" "gke-lb-health-checks-hub" {
  project = google_project.project.project_id
  network = module.vpc-hub.self_link
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gke-lb-hc-hub"

  priority  = "200"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443", "10256", "15021"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]

  target_service_accounts = [
    google_service_account.gke_service_account.email,
    google_service_account.gke_egress_service_account.email,
    google_service_account.gke_worker_service_account.email,
    google_service_account.config_connector_service_account.email,
    google_service_account.sc-mig-egress-squid.email,
  ]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}



// Create the firewall rules to allow nodes to communicate with the control plane
resource "google_compute_firewall" "gke-lb-health-checks-spoke" {
  project = google_project.project.project_id
  network = module.vpc-spoke-1.self_link
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gke-lb-hc-spoke"

  priority  = "200"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443", "10256", "15021"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]

  target_service_accounts = [
    google_service_account.gke_service_account.email,
    google_service_account.gke_egress_service_account.email,
    google_service_account.gke_worker_service_account.email,
    google_service_account.config_connector_service_account.email,
    google_service_account.sc-mig-egress-squid.email,
  ]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

