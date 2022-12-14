module "gke-gitlab" {
  source                      = "./terraform-google-gke-gitlab"
  project_id                  = google_project.project.project_id
  certmanager_email           = "no-reply@${google_project.project.project_id}.example.com"
  gitlab_deletion_protection  = false
  gitlab_db_random_prefix     = true
  helm_chart_version          = "6.6.0"
  runner_service_account_name = google_service_account.gitlab_service_account.email
  network_name                = module.vpc-spoke-1.name
  network_self_link           = module.vpc-spoke-1.self_link
}

data "google_project" "project" {
  project_id = google_project.project.project_id
}


locals {
  serviceAccountIAMRoles = [
    "roles/iam.serviceAccountUser",
    //"roles/storage.admin",
    //"roles/resourcemanager.organizationAdmin",
    //"roles/iam.workloadIdentityUser",
    //"roles/resourcemanager.projectCreator",
    //"roles/resourcemanager.projectIamAdmin",
    //"roles/container.clusterAdmin",
    //"roles/compute.admin",
  ]
}


resource "google_iam_workload_identity_pool" "gitlab_identity_pool" {
  project                   = google_project.project.project_id
  workload_identity_pool_id = "${var.prefix}-${var.demo_name}"
  display_name              = "Gitlab Identity Pool"
  description               = "Gitlab Identity Pool for automated CICD"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "gitlab_identity_pool_provider" {
  project                            = google_project.project.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.gitlab_identity_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.prefix}-${var.demo_name}-gitlab-oidc"
  display_name                       = "Gitlab OIDC Provider"
  description                        = "OIDC identity pool provider for Gitlab"
  disabled                           = false
  //attribute_condition                = ""
  attribute_mapping = {
    "google.subject"                  = "assertion.sub"
    "attribute.sub"                   = "assertion.sub"
    "attribute.environment"           = "assertion.environment"
    "attribute.environment_protected" = "assertion.environment_protected"
    "attribute.namespace_id"          = "assertion.namespace_id"
    "attribute.namespace_path"        = "assertion.namespace_path"
    "attribute.pipeline_id"           = "assertion.pipeline_id"
    "attribute.pipeline_source"       = "assertion.pipeline_source"
    "attribute.project_id"            = "assertion.project_id"
    "attribute.project_path"          = "assertion.project_path"
    "attribute.repository"            = "assertion.project_path"
    "attribute.ref"                   = "assertion.ref"
    "attribute.ref_protected"         = "assertion.ref_protected"
    "attribute.ref_type"              = "assertion.ref_type"
  }
  oidc {
    issuer_uri        = module.gke-gitlab.gitlab_url
    allowed_audiences = ["${module.gke-gitlab.gitlab_url}"]

  }
}


resource "google_service_account" "gitlab_service_account" {
  project      = google_project.project.project_id
  account_id   = "${var.prefix}-${var.demo_name}-gitlab"
  display_name = "${var.prefix}-${var.demo_name}-gitlab"
  description  = "Gitlab CI/CD Automation service account."
}

resource "google_service_account_iam_member" "gitlab_service_account_iam_member" {
  count              = length(local.serviceAccountIAMRoles)
  service_account_id = google_service_account.gitlab_service_account.name
  role               = element(local.serviceAccountIAMRoles, count.index)
  member             = "serviceAccount:${google_service_account.gitlab_service_account.email}"
}


resource "google_service_account_iam_binding" "gitlab_service_account_iam_binding" {
  service_account_id = google_service_account.gitlab_service_account.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_project.project.project_id}.svc.id.goog[default/gitlab-gitlab-runner]",
    "serviceAccount:${google_project.project.project_id}.svc.id.goog[default/default]",
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.gitlab_identity_pool.workload_identity_pool_id}/*",
  ]
}

resource "google_service_account_iam_binding" "gitlab_account_cluster_iam_binding_developer" {
  service_account_id = google_service_account.gitlab_service_account.name
  role               = "roles/container.developer"

  members = [
    "serviceAccount:${google_project.project.project_id}.svc.id.goog[default/gitlab-gitlab-runner]",
    "serviceAccount:${google_project.project.project_id}.svc.id.goog[default/default]",
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.gitlab_identity_pool.workload_identity_pool_id}/*",
  ]
}

output "GCP_WORKLOAD_IDENTITY_PROVIDER" {
  value = google_iam_workload_identity_pool_provider.gitlab_identity_pool_provider.name
}

output "GCP_SERVICE_ACCOUNT" {
  value = google_service_account.gitlab_service_account.email
}