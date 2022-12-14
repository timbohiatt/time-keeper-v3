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


locals {
  # Subnet Values
  subnet_cidr_range = coalesce(
    var.subnet_config.cidr_range, try(var.defaults.cidr_range, "")
  )
  subnet_private_google_access = coalesce(
    var.subnet_config.private_google_access, try(var.defaults.private_google_access, false)
  )
  region = coalesce(
    var.region, try(var.defaults.region, "")
  )

  cluster_name = coalesce(
    var.cluster_name, try("${var.prefix}-gke-${local.region}", "gke-cluster-${local.region}")
  )

  service_account = var.service_account

  service_account_egress = coalesce(
    var.service_account_egress, try(var.service_account, null)
  )

  service_account_internal = coalesce(
    var.service_account_internal, try(var.service_account, null)
  )

  logging_service = coalesce(
    var.logging_service, try(var.defaults.logging_service, "logging.googleapis.com/kubernetes")
  )

  monitoring_service = coalesce(
    var.monitoring_service, try(var.defaults.monitoring_service, "logging.googleapis.com/kubernetes")
  )

  enable_cost_management_config = coalesce(
    var.enable_cost_management_config, try(var.defaults.enable_cost_management_config, true)
  )

  enable_config_connector = true

  #PCC = Private Cluster config
  pcc_enable_private_endpoint = coalesce(
    var.private_cluster_config.enable_private_endpoint, try(var.defaults.private_cluster_config.enable_private_endpoint, true)
  )
  pcc_enable_private_nodes = coalesce(
    var.private_cluster_config.enable_private_nodes, try(var.defaults.private_cluster_config.enable_private_nodes, true)
  )
  pcc_master_ipv4_cidr_block = coalesce(
    var.private_cluster_config.master_ipv4_cidr_block, try(var.defaults.private_cluster_config.master_ipv4_cidr_block, true)
  )

  min_master_version = coalesce(
    var.min_master_version, try(var.defaults.min_master_version, "1.24.5")
  )

  master_global_access_config_enabled = coalesce(
    var.master_global_access_config_enabled, try(var.defaults.master_global_access_config_enabled, true)
  )

  master_authorized_networks_cidr_blocks = coalesce(
    var.master_authorized_networks_cidr_blocks, try(var.defaults.master_authorized_networks_cidr_blocks, [])
  )

}


// Create the GKE Cluster
resource "google_container_cluster" "gke" {
  provider = google-beta

  project  = var.project_id
  name     = local.cluster_name
  location = local.region

  network    = var.vpc_network_self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  logging_service    = local.logging_service
  monitoring_service = local.monitoring_service

  min_master_version = local.min_master_version

  remove_default_node_pool = true
  initial_node_count       = 1
  enable_shielded_nodes    = true
  enable_legacy_abac       = false

  resource_labels = {
    //mesh_id = "proj-${google_project.project.number}",
    usage = "workload",
  }

  cost_management_config {
    enabled = local.enable_cost_management_config
  }


  master_auth {
    // Disable login auth to the cluster
    //username = ""
    //password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  node_config {
    labels = {
      private-pool = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = "true"
      enable_integrity_monitoring = "true"
    }

    preemptible = false

    service_account = local.service_account
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_endpoint = local.pcc_enable_private_endpoint
    enable_private_nodes    = local.pcc_enable_private_nodes
    master_ipv4_cidr_block  = local.pcc_master_ipv4_cidr_block
    master_global_access_config {
      enabled = local.master_global_access_config_enabled
    }
  }


  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = local.master_authorized_networks_cidr_blocks != null ? local.master_authorized_networks_cidr_blocks : []
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  ip_allocation_policy {
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {

    config_connector_config {
      enabled = local.enable_config_connector
    }

    network_policy_config {
      disabled = false
    }
  }

  //resource_labels = var.cluster_labels

  lifecycle {
    ignore_changes = [master_auth, node_config]
  }

  timeouts {
    create = "30m"
    update = "40m"
    delete = "2h"
  }
}