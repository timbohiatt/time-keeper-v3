locals {
  health_check = {
        check_interval_sec  = 15
        timeout_sec         = 15
        healthy_threshold   = 4
        unhealthy_threshold = 4
        request_path        = "/"
        port                = 80
        host                = null
        logging             = true
  }
}

resource "google_compute_global_address" "gbl-ext-lb" {
  project = google_project.project.project_id
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gbl-ext-lb-ip"
}


module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google//modules/dynamic_backends"
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gbl-ext-lb"
  project = google_project.project.project_id

  firewall_networks = [module.vpc-hub.self_link]

  ssl = true
  managed_ssl_certificate_domains = [
    "v3.${var.env}.time-keeper.watch",
    "app.v3.${var.env}.time-keeper.watch",
    "bank.app.v3.${var.env}.time-keeper.watch",
    "ops.v3.${var.env}.time-keeper.watch",
    "argo.ops.v3.${var.env}.time-keeper.watch",
    "kiali.ops.v3.${var.env}.time-keeper.watch",
  ]
  https_redirect = true
  create_address = false
  address        = google_compute_global_address.gbl-ext-lb.self_link


  backends = {
    default = {

      description                     = null
      protocol                        = "HTTPS"
      port                            = 443
      port_name                       = "https"
      timeout_sec                     = 30
      connection_draining_timeout_sec = 0
      enable_cdn                      = true
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = local.health_check

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

       groups = []
      /*groups = [
        {
          group                        = null
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
      ]*/

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}