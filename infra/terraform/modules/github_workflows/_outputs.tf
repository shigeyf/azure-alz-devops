// _outputs.tf

output "environments" {
  value = local.environments
}

output "jobs" {
  value = local.jobs
}

output "job_reader" {
  value = local.job_plan
}

output "job_contributor" {
  value = local.job_apply
}

output "teams" {
  value = local.teams
}

output "default_github_environments" {
  value = local.default_github_environments
}

output "github_environments" {
  value = local.github_environments
}

output "workflow_main_files" {
  value = local.workflow_main_files
}

output "workflow_templates_files" {
  value = local.workflow_template_files
}

output "branch_rules" {
  value = local.branch_rules
}

output "repo_variables" {
  value = local.repo_variables
}

/*
For Debug

resource "local_file" "main" {
  for_each = local.workflow_main_files
  filename = "${path.module}/generated/main/${each.key}"
  content = each.value.content
}

resource "local_file" "templates" {
  for_each = local.workflow_template_files
  filename = "${path.module}/generated/templates/${each.key}"
  content = each.value.content
}

*/
