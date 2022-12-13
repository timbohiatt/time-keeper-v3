module "automation" {
  source = "./modules/automation"
  prefix = var.prefix    
  billing_account = var.billing_account
  folder_id = var.folder_id
  region    = var.region
  demo_name = "automation"
  project_id = google_project.project.project_id
  network_self_link = module.vpc-hub.self_link
  network_name = module.vpc-hub.name
}