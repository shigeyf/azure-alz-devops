// repo.templates.tf

resource "github_repository" "templates" {
  count                = var.use_separate_repo_for_pipeline_templates ? 1 : 0
  name                 = var.templates_repository_name
  description          = var.templates_repository_name
  auto_init            = true
  visibility           = data.github_organization.this.plan == local.free_plan ? "public" : "private"
  allow_update_branch  = true
  allow_merge_commit   = false
  allow_rebase_merge   = false
  vulnerability_alerts = true
}

resource "github_repository_file" "templates" {
  for_each            = var.use_separate_repo_for_pipeline_templates ? var.templates_repository_files : {}
  repository          = github_repository.templates[0].name
  file                = each.key
  content             = each.value.content
  commit_author       = local.default_commit_email
  commit_email        = local.default_commit_email
  commit_message      = "Added ${each.key} [skip ci]"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      commit_author,
      commit_email,
      commit_message,
    ]
  }

  depends_on = [
    github_repository.templates,
  ]
}

resource "github_branch_protection" "templates" {
  count                           = var.use_separate_repo_for_pipeline_templates && var.create_branch_policies ? 1 : 0
  repository_id                   = github_repository.templates[0].name
  pattern                         = "main"
  enforce_admins                  = true
  required_linear_history         = true
  require_conversation_resolution = true

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    restrict_dismissals             = true
    required_approving_review_count = length(local.approvers) > 1 ? 1 : 0
  }

  depends_on = [
    github_repository.templates,
    github_repository_file.templates,
  ]
}

resource "github_actions_repository_access_level" "templates" {
  count        = var.use_separate_repo_for_pipeline_templates && data.github_organization.this.plan == local.enterprise_plan ? 1 : 0
  access_level = "organization"
  repository   = github_repository.templates[0].name

  depends_on = [
    github_repository.templates,
  ]
}
