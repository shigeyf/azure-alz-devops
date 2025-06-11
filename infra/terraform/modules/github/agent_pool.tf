// agent_pool.tf

resource "github_actions_runner_group" "this" {
  count      = var.runner_group_name != "" ? 1 : 0
  name       = var.runner_group_name
  visibility = "selected"
  selected_repository_ids = (var.use_templates_repository
    ? [github_repository.this.repo_id, github_repository.templates[0].repo_id]
    : [github_repository.this.repo_id]
  )
}
