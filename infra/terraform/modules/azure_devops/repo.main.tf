// repo.module.tf

resource "azuredevops_git_repository" "this" {
  project_id     = local.project_id
  name           = var.main_repository_name
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

resource "azuredevops_git_repository_file" "this" {
  for_each            = var.main_repository_files
  repository_id       = azuredevops_git_repository.this.id
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
    azuredevops_git_repository.this,
  ]
}

# Branch policiy for merge types allowed on a specific branch
resource "azuredevops_branch_policy_merge_types" "this" {
  project_id = local.project_id
  enabled    = var.create_branch_policies
  blocking   = true

  settings {
    allow_squash                  = true
    allow_rebase_and_fast_forward = false
    allow_basic_no_fast_forward   = false
    allow_rebase_with_merge       = false

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = azuredevops_git_repository.this.default_branch
      match_type     = "Exact"
    }
  }

  depends_on = [
    azuredevops_git_repository.this,
    azuredevops_git_repository_file.this,
  ]
}

# Branch policiy for reviewers on pull requests
# to include the minimum number of reviewers and other conditions
resource "azuredevops_branch_policy_min_reviewers" "tihs" {
  project_id = local.project_id
  enabled    = length(local.approvers) > 1 && var.create_branch_policies
  blocking   = true

  settings {
    reviewer_count                         = 1
    submitter_can_vote                     = false
    last_pusher_cannot_approve             = true
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = true
    #on_last_iteration_require_vote         = false

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = azuredevops_git_repository.this.default_branch
      match_type     = "Exact"
    }
  }

  depends_on = [
    azuredevops_git_repository.this,
    azuredevops_git_repository_file.this,
  ]
}

# Branch policiy for managing a build validation
resource "azuredevops_branch_policy_build_validation" "this" {
  project_id = local.project_id
  enabled    = var.create_branch_policies
  blocking   = true

  settings {
    display_name        = "Terraform Validation"
    build_definition_id = azuredevops_build_definition.this[var.ci_pipeline_key].id
    valid_duration      = 720

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = azuredevops_git_repository.this.default_branch
      match_type     = "Exact"
    }
  }

  depends_on = [
    azuredevops_git_repository.this,
    azuredevops_git_repository_file.this,
    azuredevops_build_definition.this,
  ]
}
