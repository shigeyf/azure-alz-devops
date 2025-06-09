// role.rule_set.tf

resource "github_repository_ruleset" "this" {
  for_each    = var.branch_rules
  name        = each.value.name
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/${each.value.branch_name}"]
      exclude = []
    }
  }

  rules {
    creation                      = each.value.rules.creation
    deletion                      = each.value.rules.deletion
    update                        = each.value.rules.update
    non_fast_forward              = each.value.rules.non_fast_forward
    required_linear_history       = each.value.rules.required_linear_history
    required_signatures           = each.value.rules.required_signatures
    update_allows_fetch_and_merge = each.value.rules.update_allows_fetch_and_merge

    dynamic "pull_request" {
      for_each = each.value.rules.pull_request != null ? [1] : []
      content {
        dismiss_stale_reviews_on_push     = each.value.rules.pull_request.dismiss_stale_reviews_on_push
        require_code_owner_review         = each.value.rules.pull_request.require_code_owner_review
        require_last_push_approval        = each.value.rules.pull_request.require_last_push_approval
        required_approving_review_count   = each.value.rules.pull_request.required_approving_review_count
        required_review_thread_resolution = each.value.rules.pull_request.required_review_thread_resolution
      }
    }

    dynamic "required_deployments" {
      for_each = (
        each.value.rules.required_deployments != null
        && length(each.value.rules.required_deployments.required_deployment_environments) > 0
        ? [1] : []
      )
      content {
        required_deployment_environments = each.value.rules.required_deployments.required_deployment_environments
      }
    }

    dynamic "required_status_checks" {
      for_each = (
        each.value.rules.required_status_checks != null
        && length(each.value.rules.required_status_checks.required_checks) > 0
        ? [1] : []
      )
      content {
        do_not_enforce_on_create             = each.value.rules.required_status_checks.do_not_enforce_on_create
        strict_required_status_checks_policy = each.value.rules.required_status_checks.strict_required_status_checks_policy
        dynamic "required_check" {
          for_each = each.value.rules.required_status_checks.required_checks
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }
  }

  depends_on = [
    github_repository.this,
    github_branch.this,
  ]
}
