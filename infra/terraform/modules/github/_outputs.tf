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

output "subjects" {
  value = local.oidc_subjects
}

output "issuer" {
  value = "https://token.actions.githubusercontent.com"
}

output "agent_pool_name" {
  value = var.use_self_hosted_agents ? github_actions_runner_group.this[0].name : null
}

output "repositories" {
  value = {
    main      = github_repository.this.http_clone_url
    templates = var.use_separate_repo_for_pipeline_templates ? github_repository.templates[0].http_clone_url : null
  }
}
