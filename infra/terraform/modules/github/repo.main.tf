// repo.main.tf

resource "github_repository" "this" {
  name                 = var.main_repository_name
  description          = var.main_repository_name
  auto_init            = true
  visibility           = data.github_organization.this.plan == local.free_plan ? "public" : "private"
  allow_update_branch  = true
  allow_merge_commit   = false
  allow_rebase_merge   = false
  vulnerability_alerts = true
}

resource "github_repository_file" "this" {
  for_each            = var.main_repository_files
  repository          = github_repository.this.name
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
    github_repository.this,
  ]
}

resource "github_branch_protection" "this" {
  count                           = var.create_branch_policies ? 1 : 0
  repository_id                   = github_repository.this.name
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
    github_repository.this,
    github_repository_file.this,
  ]
}
