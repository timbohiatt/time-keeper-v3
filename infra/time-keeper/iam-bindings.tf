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
  CCServiceAccountIAMRoles = [
    "roles/owner",
    "roles/editor",
    "roles/iam.workloadIdentityUser",
  ]
  GKEServiceAccountIAMRoles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ]
  GitLabServiceAccountIAMRoles = [
    "roles/owner",
    "roles/editor",
    "roles/container.developer",
  ]
}


resource "google_project_iam_member" "autoneg_workload_identity" {
  project = google_project.project.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_project.project.project_id}.svc.id.goog[autoneg-system/autoneg]"
}

resource "google_project_iam_member" "config_connector_service_account" {
  count   = length(local.CCServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.CCServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${google_service_account.config_connector_service_account.email}"
}

resource "google_project_iam_member" "gke_service_account" {
  count   = length(local.GKEServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.GKEServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

resource "google_project_iam_member" "gke_service_account_worker" {
  count   = length(local.GKEServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.GKEServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${google_service_account.gke_worker_service_account.email}"
}

resource "google_project_iam_member" "gke_service_account_external" {
  count   = length(local.GKEServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.GKEServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${google_service_account.gke_egress_service_account.email}"
}

resource "google_project_iam_member" "gitlab_service_account" {
  count   = length(local.GitLabServiceAccountIAMRoles)
  project = google_project.project.project_id
  role    = element(local.GitLabServiceAccountIAMRoles, count.index)
  member  = "serviceAccount:${var.GitLabServiceAccountEmail}"
}