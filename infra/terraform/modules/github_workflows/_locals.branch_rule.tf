// _locals.branch_rule.tf

locals {
  branch_name_check             = "validate_pr_branches"
  github_actions_integration_id = 15368

  branch_rules = {
    for env in local.environment_mappings : env.branch_key => {
      name        = "Branch Protection: ${env.name}"
      branch_name = env.branch_key
      description = "Protection Rule set for the ${env.branch_key} branch"
      rules = {
        creation                      = false
        deletion                      = true
        update                        = false
        non_fast_forward              = true
        required_linear_history       = false
        required_signatures           = false
        update_allows_fetch_and_merge = false
        pull_request = {
          dismiss_stale_reviews_on_push     = true
          require_code_owner_review         = env.enable_code_owner_reviews
          require_last_push_approval        = false
          required_approving_review_count   = env.review_count
          required_review_thread_resolution = true
        }
        required_status_checks = {
          do_not_enforce_on_create             = false
          strict_required_status_checks_policy = false
          required_checks = [
            {
              context        = local.branch_name_check
              integration_id = local.github_actions_integration_id
            }
          ]
        }
      }
    } if env.enable_branch_rules
  }
}
