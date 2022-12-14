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

resource "random_integer" "np_ext_salt" {
  min = 0001
  max = 9999
}

resource "google_container_node_pool" "np-external" {
  project  = var.project_id
  name     = "np-${local.region}-ext-${random_integer.np_ext_salt.result}"
  location = local.region
  cluster  = google_container_cluster.gke.name

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = "e2-standard-2"

    disk_size_gb = 100
    disk_type    = "pd-balanced"

    preemptible = false

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      private-pool = "true",
      type         = "egress"
    }

    // Prevents GKE from Scheduling Workloads on this node pool unless they have the key value pair in the Taint. 
    // This Node Pool is Firewall Blocked for INGRESS and Allows ONLY EGRESS traffic.
    taint = [{
      key    = "dedicated"
      value  = "gateway"
      effect = "NO_SCHEDULE"
    }]


    shielded_instance_config {
      enable_secure_boot          = "true"
      enable_integrity_monitoring = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    service_account = local.service_account_egress
  }

  initial_node_count = 1

  autoscaling {
    min_node_count  = 1
    max_node_count  = 5
    location_policy = "BALANCED"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  timeouts {
    create = "30m"
    update = "40m"
    delete = "2h"
  }

}