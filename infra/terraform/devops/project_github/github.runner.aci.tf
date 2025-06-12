// github.runner.aci.tf

module "github_runner_aci" {
  count               = var.use_self_hosted_runners && var.self_hosted_runners_type == "aci" ? 1 : 0
  source              = "../../modules/aci"
  resource_group_name = local.agents_resource_group_name
  location            = var.location
  tags                = var.tags

  acr_login_server                          = local.acr_login_server
  container_run_managed_identity_id         = local.container_run_managed_identity_id
  keyvault_id                               = local.bootstrap.keyvault_id
  container_instance_name                   = local.container_instance_name
  container_instance_count                  = 2
  container_instance_enable_private_network = local.options.private_network_enabled
  container_instance_subnet_id              = local.container_instance_subnet_id
  container_instance_spec                   = local.container_specs.github_runner_aci.container.aci
  log_analytics_workspace_id                = local._devops_outputs.devops_agents.log_analytics_id
}

output "github_runner_aci_container_spec" {
  value = local.container_specs.github_runner_aci.container.aci
}
