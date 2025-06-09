// repo.templates.tf

resource "github_repository" "templates" {
  count                  = var.use_templates_repository ? 1 : 0
  name                   = var.templates_repository_name
  description            = var.templates_repository_name
  auto_init              = true
  visibility             = data.github_organization.this.plan == local.free_plan ? "public" : "private"
  allow_merge_commit     = true
  allow_squash_merge     = false
  allow_rebase_merge     = false
  allow_update_branch    = false
  delete_branch_on_merge = false
  has_issues             = true
  has_projects           = true
  vulnerability_alerts   = true
}

resource "github_repository_file" "templates" {
  for_each            = var.use_templates_repository ? var.templates_repository_files : {}
  repository          = github_repository.templates[0].name
  file                = each.key
  content             = each.value.content
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
resource "github_actions_repository_access_level" "templates" {
  count        = var.use_templates_repository ? 1 : 0
  access_level = "organization"
  repository   = github_repository.templates[0].name

  depends_on = [
    github_repository.templates,
  ]
}
