// organization.tf

data "github_organization" "this" {
  name = var.organization_name
}
