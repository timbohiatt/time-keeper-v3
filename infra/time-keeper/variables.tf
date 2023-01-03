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

variable "gke_data_dir" {
  description = "Relative path for the folder storing configuration data."
  type        = string
  default     = "data/gke/clusters"
}

variable "gke_defaults_file" {
  description = "Relative path for the file storing the project factory configuration."
  type        = string
  default     = "data/gke/defaults.yaml"
}

variable "prefix" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "region" {
  type = string
}

variable "master_ipv4_cidr_block" {
}

variable "demo_name" {
  type = string
}

variable "env" {
  type = string
}

variable "GitLabServiceAccountEmail" {
  type    = string
  default = "tk-automation-gitlab@tk-automation-1483.iam.gserviceaccount.com"
}



///////// V3 Additions 

variable "ip_ranges" {
  description = "IP CIDR ranges."
  type        = map(string)
  default = {
    hub     = "10.0.0.0/24"
    spoke-1 = "10.0.32.0/24"
    spoke-2 = "10.0.16.0/24"
  }
}

variable "ip_secondary_ranges" {
  description = "Secondary IP CIDR ranges."
  type        = map(string)
  default = {
    spoke-1-pods     = "10.128.0.0/18"
    spoke-1-services = "172.16.0.0/24"
  }
}


variable "domain" {
  type = string
}