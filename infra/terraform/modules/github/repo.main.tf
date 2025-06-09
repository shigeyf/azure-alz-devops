// repo.main.tf

locals {
  _create_branches = [for r in var.branch_rules : r.branch_name]
}

resource "github_repository" "this" {
  name                   = var.main_repository_name
  description            = var.main_repository_name
  auto_init              = true
  visibility             = data.github_organization.this.plan == local.free_plan ? "public" : "private"
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  allow_update_branch    = false
  delete_branch_on_merge = false
  has_issues             = true
  has_projects           = true
  vulnerability_alerts   = true
}

resource "github_repository_file" "this" {
  for_each = (var.use_templates_repository
    ? var.main_repository_files
    : merge(var.main_repository_files, var.templates_repository_files)
  )
  repository          = github_repository.this.name
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
    github_repository.this,
  ]
}

resource "github_branch" "this" {
  for_each   = { for branch in local._create_branches : branch => branch if branch != "main" }
  repository = github_repository.this.name
  branch     = each.value

  depends_on = [
    github_repository.this,
    github_repository_file.this,
  ]
}
