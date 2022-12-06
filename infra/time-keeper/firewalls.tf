
// Create the firewall rules to allow nodes to communicate with the control plane
resource "google_compute_firewall" "gke-lb-health-checks" {
  project = google_project.project.project_id
  network = module.vpc-spoke-1.self_link
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gke-lb-hc"

  priority  = "200"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]

  target_service_accounts = [
    google_service_account.gke_service_account.email,
    google_service_account.gke_egress_service_account.email,
    google_service_account.gke_worker_service_account.email

  ]
}

