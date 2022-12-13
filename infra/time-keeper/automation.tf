module "automation" {
  source = "./modules/automation"
  prefix = var.prefix    
  billing_account = var.billing_account
  folder_id = var.folder_id
  region    = var.region
  demo_name = "automation"
}