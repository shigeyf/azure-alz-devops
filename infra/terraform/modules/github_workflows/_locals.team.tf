// _locals.team.tf

locals {
  pullrequest_reviewers_format = "%s-%s-pullrequest-approvers"
  environment_reviewers_format = "%s-%s-deployment-approvers"

  teams_contributors = {
    "${var.project_name}-contributors" = {
      description = "Contributors to the project repository"
      permission  = "push"
    },
  }

  teams_pullrequest_reviewers = {
    for branch in local.pullrequest_review_branches :
    format(local.pullrequest_reviewers_format, var.project_name, branch) => {
      description = "Approvers for staging ${branch} pull requests"
      permission  = "push"
    }
  }

  _teams_environment_reviewers = flatten([for wf in local.workflows :
    [for env_key, env in wf.environments :
      {
        name        = format(local.environment_reviewers_format, var.project_name, local.environment_mappings[env_key].branch_key)
        description = "Approvers for ${local.environment_mappings[env_key].branch_key} branch depolyments"
        permission  = "maintain"
      } if env.required_reviewers
    ]
  ])
  teams_environment_reviewers = { for item in local._teams_environment_reviewers :
    item.name => {
      description = item.description
      permission  = item.permission
    }
  }

  teams = merge(
    local.teams_contributors,
    local.teams_pullrequest_reviewers,
    local.teams_environment_reviewers,
  )
}
