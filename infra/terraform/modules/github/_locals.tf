// _locals.tf

locals {
  free_plan = "free"
  # enterprise_plan = "enterprise"
}

locals {
  organization_url = "https://${var.organization_domain_name}/${var.organization_name}"
  api_base_url     = "https://${var.api_domain_name}/"
}

locals {
  # default_branch = "refs/heads/main"
}
