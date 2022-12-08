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


/*resource "kubernetes_cluster_role_binding" "cluster-admin-role" {

  metadata {
    name = "jump-vm"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
 subject {
    kind      = "ServiceAccount"
    name      = "${google_service_account.jump-vm.email}"
    api_group = "rbac.authorization.k8s.io"
  }
}*/


resource "google_compute_firewall" "jump-ssh-allow" {
  project   = google_project.project.project_id
  network   = module.vpc-spoke-1.self_link
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
  name          = "${var.prefix}-${var.demo_name}-${var.env}-iap"
  priority      = "1000"
}


resource "google_service_account" "jump-vm" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.env}-jump-vm"
  display_name = "Service Account jump-vm"
}

resource "google_project_iam_member" "jump-vm-admin" {
  project = google_project.project.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.jump-vm.email}"
}

resource "google_compute_instance" "jump-vm" {
  project      = google_project.project.project_id
  name         = "${var.prefix}-${var.demo_name}-${var.env}-jump-vm"
  machine_type = "n2-standard-8"
  zone         = "europe-west6-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    //network = google_compute_network.vpc-global.self_link
    subnetwork = google_compute_subnetwork.subnet-jump-vm.self_link

    //access_config {
    // Ephemeral public IP
    //}
  }

  metadata_startup_script = "sudo apt-get install git kubectl google-cloud-sdk-gke-gcloud-auth-plugin -y && git clone https://github.com/timbohiatt/time-keeper-v3 && cd time-keeper && git checkout timhiatt/v3.0"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.jump-vm.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_project_metadata" "enable-oslogin" {
  project = google_project.project.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "subnet-jump-vm" {
  project                  = google_project.project.project_id
  network                  = module.vpc-spoke-1.self_link
  name                     = "${var.prefix}-gke-${var.region}-sub-mytimekeeper-jump-vm"
  region                   = var.region
  ip_cidr_range            = "10.128.40.0/21"
  private_ip_google_access = true
}

/*
module "nat-jump-vm" {
  source         = "./modules/net-cloudnat"
  project_id     = google_project.project.project_id
  region         = var.region
  name           = "${var.prefix}-${var.demo_name}-${var.env}-${var.region}-jump-vm-nat"
  router_name    = "${var.prefix}-${var.demo_name}-${var.env}-${var.region}-jump-vm-rtr"
  router_network = module.vpc-spoke-1.self_link
}*/