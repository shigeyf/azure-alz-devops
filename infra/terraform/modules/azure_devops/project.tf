// project.tf

data "azuredevops_project" "this" {
  count = var.create_project ? 0 : 1
  name  = var.project_name
}

resource "azuredevops_project" "this" {
  count              = var.create_project ? 1 : 0
  name               = var.project_name
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
  description        = "DevOps Managed by Terraform"
  //features = {}
}

locals {
  project_id = var.create_project ? azuredevops_project.this[0].id : data.azuredevops_project.this[0].id
}
