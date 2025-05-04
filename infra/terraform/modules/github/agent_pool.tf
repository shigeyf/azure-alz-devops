// agent_pool.tf

resource "github_actions_runner_group" "this" {
  count      = var.use_self_hosted_agents ? 1 : 0
  name       = var.agent_pool_name
  visibility = "selected"
  selected_repository_ids = (var.use_separate_repo_for_pipeline_templates
    ? [github_repository.this.repo_id, github_repository.templates[0].repo_id]
    : [github_repository.this.repo_id]
  )
}
