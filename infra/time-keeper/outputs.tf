/**
 * Copyright 2018 Google LLC
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

output "PROJECT_ID" {
  value = google_project.project.project_id
}

output "GKE_CLUSTERS" {
  value = module.gke_region
}


output "gl_root_password_instructions" {
  value = module.gke-gitlab.root_password_instructions
}

output "gl_root_gitlab_url" {
  value = module.gke-gitlab.gitlab_url
}




