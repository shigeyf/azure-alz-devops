// _locals.tf

locals {
  repository_name           = var.project_name
  templates_repository_name = "${var.project_name}-templates"
  uami_name_prefix          = "uami-${substr(module.naming.user_assigned_identity.name, 4, -1)}-${local.rand_id}-"
}
