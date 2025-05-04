// _outputs.tf

output "organization_url" {
  value = local.organization_url
}

output "subjects" {
  value = {
    for key, value in var.environments
    : key => azuredevops_serviceendpoint_azurerm.this[key].workload_identity_federation_subject
  }
}

output "issuers" {
  value = {
    for key, value in var.environments
    : key => azuredevops_serviceendpoint_azurerm.this[key].workload_identity_federation_issuer
  }
}

output "agent_pool_name" {
  value = var.use_self_hosted_agents ? azuredevops_agent_pool.this[0].name : null
}

output "repositories" {
  value = {
    main      = azuredevops_git_repository.this.remote_url
    templates = var.use_separate_repo_for_pipeline_templates ? azuredevops_git_repository.templates[0].remote_url : null
  }
}
