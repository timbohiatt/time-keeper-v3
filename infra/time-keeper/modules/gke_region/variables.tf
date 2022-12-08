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

variable "project_id" {
  description = "Project id."
  type        = string
}

variable "prefix" {
  description = "GCP Resource Prefix"
  type        = string
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
}

variable "region" {
  description = "GCP Region for Cluster"
  type        = string
}

variable "logging_service" {
  description = "GKE Logging Service"
  type        = string
}

variable "monitoring_service" {
  description = "GKE Monitoring Service"
  type        = string
}

variable "min_master_version" {
  description = "GKE Master Node Minimum Cluster Version"
  type        = string
}

variable "enable_cost_management_config" {
  description = "Enable GKE Cost Management Service"
  type        = bool
}

variable "vpc_network_self_link" {
  description = "GCP Network Self Link"
  type        = string
}

variable "subnet_config" {
  description = "GKE Subnet Configuration values."
  type = object({
    cidr_range            = optional(string)
    private_google_access = optional(bool)
  })
}

variable "master_global_access_config_enabled" {
  description = "Master Global Access Configuration"
  type        = bool
}

variable "private_cluster_config" {
  description = "GKE Private Master Config."
  type = object({
    enable_private_endpoint = optional(bool)
    enable_private_nodes    = optional(bool)
    master_ipv4_cidr_block  = optional(string)
  })
}

variable "defaults" {
  description = "GKE Cluster factory default values."
  type = object({
    enabled            = bool
    region             = string
    min_master_version = optional(string)
    subnet_config = object({
      cidr_range            = optional(string)
      private_google_access = optional(bool)
    })
    master_global_access_config_enabled = optional(bool)
    private_cluster_config = object({
      enable_private_endpoint = optional(bool)
      enable_private_nodes    = optional(bool)
      master_ipv4_cidr_block  = optional(string)
    })
    logging_service                        = optional(string)
    monitoring_service                     = optional(string)
    enable_cost_management_config          = optional(bool)
    master_authorized_networks_cidr_blocks = optional(list(map(string)))
  })
  default = null
}

variable "service_account" {
  description = "GCP Service Account Email for GKE"
  type        = string
}

variable "service_account_egress" {
  description = "GCP Service Account Email for GKE Egress Node Pool"
  type        = string
  default     = null
}

variable "service_account_internal" {
  description = "GCP Service Account Email for GKE Internal Node Pool"
  type        = string
  default     = null
}

variable "master_authorized_networks_cidr_blocks" {
  type        = list(map(string))
  default     = []
  description = "Defines up to 20 external networks that can access Kubernetes master through HTTPS."
}