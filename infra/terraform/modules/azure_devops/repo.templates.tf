// repo.templates.tf

resource "azuredevops_git_repository" "templates" {
  count          = var.use_separate_repo_for_pipeline_templates ? 1 : 0
  project_id     = local.project_id
  name           = var.templates_repository_name
  default_branch = local.default_branch
  initialization {
    init_type = "Clean"
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to initiation to support importing existing repositories
      initialization,
    ]
  }
}

resource "azuredevops_git_repository_file" "templates" {
  for_each            = var.use_separate_repo_for_pipeline_templates ? var.templates_repository_files : {}
  repository_id       = azuredevops_git_repository.templates[0].id
  file                = each.key
  content             = each.value.content
  branch              = local.default_branch
  commit_message      = "Added ${each.key} [skip ci]"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      author_name,
      author_email,
      committer_name,
      committer_email,
      commit_message,
    ]
  }

  depends_on = [
    azuredevops_git_repository.templates,
  ]
}

# Branch policiy for merge types allowed on a specific branch
resource "azuredevops_branch_policy_merge_types" "templates" {
  count      = var.use_separate_repo_for_pipeline_templates ? 1 : 0
  project_id = local.project_id
  enabled    = var.create_branch_policies
  blocking   = true

  settings {
    allow_squash                  = true
    allow_rebase_and_fast_forward = false
    allow_basic_no_fast_forward   = false
    allow_rebase_with_merge       = false

    scope {
      repository_id  = azuredevops_git_repository.templates[0].id
      repository_ref = azuredevops_git_repository.templates[0].default_branch
      match_type     = "Exact"
    }
  }

  depends_on = [
    azuredevops_git_repository.templates,
    azuredevops_git_repository_file.templates,
  ]
}
