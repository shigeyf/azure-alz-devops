// _locals.tf

locals {
  organization_url = (
    startswith(lower(var.organization_name), "https://") || startswith(lower(var.organization_name), "http://")
    ? var.organization_name
    : (
      var.use_legacy_organization_url
      ? "https://${var.organization_name}.visualstudio.com"
      : "https://dev.azure.com/${var.organization_name}"
    )
  )
}

locals {
  default_branch = "refs/heads/main"
}
