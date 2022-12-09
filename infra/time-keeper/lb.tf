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

resource "google_compute_global_address" "gbl-ext-lb" {
  project = google_project.project.project_id
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gbl-ext-lb-ip"
}

resource "google_compute_managed_ssl_certificate" "lb" {
  project = google_project.project.project_id
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gbl-ext-lb-cert"

  managed {
    domains = [
      "v3.${var.env}.time-keeper.watch",
      "apps.v3.${var.env}.time-keeper.watch",
      "bank.apps.v3.${var.env}.time-keeper.watch",
      "ops.v3.${var.env}.time-keeper.watch",
      "argo.ops.v3.${var.env}.time-keeper.watch",
      "kiali.ops.v3.${var.env}.time-keeper.watch",
    ]
  }
}

module "load_balancer" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/dynamic_backends"
  name    = "${var.prefix}-${var.demo_name}-${var.env}-gbl-ext-lb"
  project = google_project.project.project_id

  enable_ipv6         = true
  create_ipv6_address = true
  http_forward        = false

  #load_balancing_scheme = "EXTERNAL_MANAGED"

  firewall_networks = [module.vpc-hub.self_link]


  ssl                  = true
  use_ssl_certificates = true
  ssl_certificates = [
    google_compute_managed_ssl_certificate.lb.self_link
  ]

  
  https_redirect = true
  create_address = false
  address        = google_compute_global_address.gbl-ext-lb.self_link

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 8080
      port_name                       = "http"
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
        request_path        = "/"
        port                = 8080
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
