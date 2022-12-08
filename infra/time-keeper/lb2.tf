module "load_balancer" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/dynamic_backends"

  name                = "dynamic-backend-lb"
  project             = var.project
  enable_ipv6         = true
  create_ipv6_address = true
  http_forward        = false

  load_balancing_scheme = "EXTERNAL_MANAGED"

  ssl                  = true
  use_ssl_certificates = true
  ssl_certificates = [
    google_compute_managed_ssl_certificate.frontend.self_link
  ]

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTPS"
      port                            = 443
      port_name                       = "https"
      timeout_sec                     = 30
      connection_draining_timeout_sec = 0
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null
      compression_mode                = null

      health_check = {
        check_interval_sec  = 15
        timeout_sec         = 15
        healthy_threshold   = 4
        unhealthy_threshold = 4
        request_path        = "/api/health"
        port                = 443
        host                = null
        logging             = true
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      # leave blank, NEGs are dynamically added to the lb via autoneg
      groups = []

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}