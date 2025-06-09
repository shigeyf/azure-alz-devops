// _locals.env.tf

locals {
  github_environment_name_prefix = "env-${var.project_name}-"

  env_feat = "features"
  env_dev  = "development"
  env_stg  = "staging"
  env_prod = "production"

  environments = [
    local.env_feat,
    local.env_dev,
    local.env_stg,
    local.env_prod,
  ]
  environment_mappings = {
    (local.env_feat) = {
      name                      = "features"
      branch_key                = "features"
      branch                    = "refs/heads/features/*"
      enable_branch_rules       = false
      enable_code_owner_reviews = false
      review_count              = 0
    },
    (local.env_dev) = {
      name                      = "development"
      branch_key                = "dev"
      branch                    = "refs/heads/dev"
      enable_branch_rules       = true
      enable_code_owner_reviews = false
      review_count              = 0
    },
    (local.env_stg) = {
      name                      = "staging"
      branch_key                = "staging"
      branch                    = "refs/heads/staging"
      enable_branch_rules       = true
      enable_code_owner_reviews = false
      review_count              = 1
    },
    (local.env_prod) = {
      name                      = "production"
      branch_key                = "main"
      branch                    = "refs/heads/main"
      enable_branch_rules       = true
      enable_code_owner_reviews = false
      review_count              = 1
    },
  }

  default_github_environments = {
    for job in local.jobs : "default-${job}" => "${local.github_environment_name_prefix}default-${job}"
  }

  github_environments = { for item in flatten([for job in local.workflows :
    [for env_key, env in job.environments :
      {
        key = "${local.environment_mappings[env_key].branch_key}-${job.key}"
        value = {
          name                          = "${local.github_environment_name_prefix}${local.environment_mappings[env_key].branch_key}-${job.key}"
          job                           = job.key
          environment                   = env_key
          can_admins_bypass             = env.admin_bypass
          prevent_self_review           = false
          wait_timer                    = env.wait_timer
          reviewers                     = env.required_reviewers ? [format(local.environment_reviewers_format, var.project_name, local.environment_mappings[env_key].branch_key)] : []
          protected_branches            = false
          custom_branch_policies        = true
          branch_policy_branch_patterns = env.source_branch_patterns
          branch_policy_tag_patterns    = []
        }
      }
    ]]) :
    item.key => item.value
  }
}
