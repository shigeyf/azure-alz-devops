// _locals.job.tf

locals {
  job_plan  = "plan"
  job_apply = "apply"
  jobs      = [local.job_plan, local.job_apply]
}

locals {
  pullrequest_review_branches = ["staging", "main"]

  workflows = {
    (local.job_plan) = {
      key = local.job_plan
      template_files = [
        "${local.github_actions_root}/${local.ci_template_filename}",
        "${local.github_actions_root}/${local.cd_template_filename}",
      ]
      environments = {
        (local.env_feat) = {
          admin_bypass           = true
          required_reviewers     = false
          wait_timer             = 0
          source_branch_patterns = ["features/*"]
        }
        (local.env_dev) = {
          admin_bypass           = true
          required_reviewers     = false
          wait_timer             = 0
          source_branch_patterns = ["features/*", "dev"]
        }
        (local.env_stg) = {
          admin_bypass           = true
          required_reviewers     = false
          wait_timer             = 0
          source_branch_patterns = ["dev", "staging"]
        }
        (local.env_prod) = {
          admin_bypass           = true
          required_reviewers     = false
          wait_timer             = 0
          source_branch_patterns = ["staging", "main"]
        }
      }
    }
    (local.job_apply) = {
      key = local.job_apply
      template_files = [
        "${local.github_actions_root}/${local.cd_template_filename}",
      ]
      environments = {
        (local.env_dev) = {
          admin_bypass           = true
          required_reviewers     = false
          wait_timer             = 0
          source_branch_patterns = ["dev"]
        }
        (local.env_stg) = {
          admin_bypass           = true
          required_reviewers     = true
          wait_timer             = 0
          source_branch_patterns = ["staging"]
        }
        (local.env_prod) = {
          admin_bypass           = true
          required_reviewers     = true
          wait_timer             = 1
          source_branch_patterns = ["main"]
        }
      }
    }
  }
}
