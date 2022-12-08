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

resource "google_compute_subnetwork" "subnet" {
  project = var.project_id
  network = var.vpc_network_self_link
  //name                     = "${var.prefix}-gke-${var.region}"
  name                     = "${var.prefix}-gke-${var.region}-sub-mytimekeeper"
  region                   = var.region
  ip_cidr_range            = local.subnet_cidr_range
  private_ip_google_access = local.subnet_private_google_access
}