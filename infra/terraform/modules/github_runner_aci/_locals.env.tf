// _locals.env.tf

/*
DevOps Self-hosted Agent Container Image
https://github.com/Azure/avm-container-images-cicd-agents-and-runners/github-runner-aca

| Name                 | Description                                                             |
| -------------------- | ----------------------------------------------------------------------- |
| GH_RUNNER_TOKEN      | The token used to authenticate the runner with GitHub.                  |
|                      |  This can be a PAT or a self-hosted runner token. If supplying a        |
|                      |  self-hosted runner token, be aware that the token will expire after    |
|                      |  a few hours, so will only work with persistent runners.                |
| GH_RUNNER_URL        | The URL of the GitHub repository or organization                        |
|                      |  (e.g. https://github.com/my-org or https://github.com/my-org/my-repo). |
| GH_RUNNER_NAME       | The name of the runner as it appears in GitHub.                         |
| GH_RUNNER_GROUP      | Optional. If not supplied, the runner will be added to the default      |
|                      |  group. This requires Enterprise licening.                              |
| GH_RUNNER_MODE       | Supported values are ephemeral and persistent.                          |
|                      | Default is ephemeral if the env var is not supplied.                    |
*/

locals {
  environment_variables = [
    {
      secret = true
      name   = "GH_RUNNER_TOKEN"
      value  = var.runner_pat_secret_id
    },
    {
      secret = false
      name   = "GH_RUNNER_URL"
      value  = "https://github.com/${var.organization_name}/{project_name}"
    },
    {
      secret = false
      name   = "GH_RUNNER_NAME"
      value  = local.runner_name
    },
    {
      secret = false
      name   = "GH_RUNNER_GROUP"
      value  = local.runner_group_name
    },
    {
      secret = false
      name   = "GH_RUNNER_MODE"
      value  = "ephemeral"
    },
  ]
}
