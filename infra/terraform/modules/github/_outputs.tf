// _outputs.tf

output "api_base_url" {
  value = local.api_base_url
}

output "organization_plan" {
  value = data.github_organization.this.plan
}
output "organization_url" {
  value = local.organization_url
}

output "repositories" {
  value = {
    main      = github_repository.this.http_clone_url
    templates = var.use_templates_repository ? github_repository.templates[0].http_clone_url : null
  }
}

output "federations" {
  value = local.oidc_fedarations
}

output "agent_pool_name" {
  value = var.use_self_hosted_agents ? github_actions_runner_group.this[0].name : null
}
