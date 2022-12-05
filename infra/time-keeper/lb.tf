resource "google_compute_global_address" "gbl-ext-lb" {
  project = google_project.project.project_id
  name = "${var.prefix}-${var.demo_name}-${var.env}-gbl-ext-lb-ip"
}

/*
module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 6.0"
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gbl-ext-lb"
  project = google_project.project.project_id
  target_tags = [
  //  "${var.network_prefix}-group1",
  //  module.cloud-nat-group1.router_name,
  //  "${var.network_prefix}-group2",
  //  module.cloud-nat-group2.router_name
  ]
  firewall_networks = [
      module.vpc-hub.name,
      module.vpc-spoke-1.name
  ]

  ssl                             = true
  managed_ssl_certificate_domains = ["v3.time-keeper.watch"]
  https_redirect    = true

  backends = {
    default = {

      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = module.gke_region.name
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}*/