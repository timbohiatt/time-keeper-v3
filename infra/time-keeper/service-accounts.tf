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

resource "google_service_account" "billing_data_admin" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-billing-data"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-billing-admin"
}

resource "google_service_account" "config_connector_service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-config-connector"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-config-connector"
}

resource "google_service_account" "gke_service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-gke"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-gke"
}

resource "google_service_account" "gke_egress_service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-gke-egress"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-gke-egress"
}

resource "google_service_account" "gke_worker_service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-gke-worker"
  display_name = "${var.prefix}-${var.demo_name}-${var.env}-gke-worker"
}


resource "google_project_iam_member" "gke_service_account_iam_editor" {
  project = google_project.project.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

resource "google_project_iam_member" "gke_service_account_iam_cluster_admin" {
  project = google_project.project.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}