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

resource "google_dns_managed_zone" "dns-zone" {
  project     = google_project.project.project_id
  name        = "v3-lcl-time-keeper-watch"
  dns_name    = "v3.lcl.time-keeper.watch."
  description = "v3 lcl time keeper zone"
}

resource "google_dns_record_set" "record-1" {
  project = google_project.project.project_id
  name    = google_dns_managed_zone.dns-zone.dns_name
  type    = "A"
  ttl     = 60

  managed_zone = google_dns_managed_zone.dns-zone.name

  rrdatas = [google_compute_global_address.gbl-ext-ip.address]
}

resource "google_dns_record_set" "record-2" {
  project = google_project.project.project_id
  name    = "*.${google_dns_managed_zone.dns-zone.dns_name}"
  type    = "A"
  ttl     = 60

  managed_zone = google_dns_managed_zone.dns-zone.name

  rrdatas = [google_compute_global_address.gbl-ext-ip.address]
}
