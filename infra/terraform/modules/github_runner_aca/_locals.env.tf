// _locals.env.tf

/*
DevOps Self-hosted Agent Container Image
https://github.com/Azure/avm-container-images-cicd-agents-and-runners/github-runner-aca

| Name                 | Description                                                         |
| -------------------- | ------------------------------------------------------------------- |
| REPO_URL             | The URL of the repository to add the runner to.                     |
| ORG_NAME             | The name of the organization that the repository belongs to.        |
| ENTERPRISE_NAME      | The name of the enterprise that the repository belongs to.          |
| ACCESS_TOKEN         | The token used to authenticate the runner with GitHub.              |
|                      | This is a PAT (Personal Access Token) with the relevant scopes that |
|                      |  requires a long expiration date.                                   |
| RUNNER_NAME_PREFIX   | The prefix for the runner name.                                     |
| RANDOM_RUNNER_SUFFIX | Whether to add a random string to the RUNNER_NAME_PREFIX to create  |
|                      |  a unique runner name. Default is true.                             |
| RUNNER_SCOPE         | The scope of the runner. Valid values are repo, org and ent.        |
| RUNNER_GROUP         | The runner group if using them.                                     |
| EPHEMERAL            | Whether the runner is ephemeral or not.                             |
*/

locals {
  environment_variables = [
    {
      secret        = false
      name          = "ORG_NAME"
      value         = var.organization_name
      kv_secret_id  = ""
      keda_metadata = "owner"
    },
    {
      secret        = false
      name          = "ENTERPRISE_NAME"
      value         = var.enterprise_name
      kv_secret_id  = ""
      keda_metadata = ""
    },
    {
      secret        = true
      name          = "ACCESS_TOKEN"
      value         = local.github_access_token_secret_name
      kv_secret_id  = var.runner_pat_secret_id
      keda_metadata = "personalAccessToken"
    },
    {
      secret        = false
      name          = "RUNNER_NAME_PREFIX"
      value         = local.runner_name
      kv_secret_id  = ""
      keda_metadata = ""
    },
    {
      secret        = false
      name          = "RUNNER_GROUP"
      value         = local.runner_group_name
      kv_secret_id  = ""
      keda_metadata = ""
    },
    {
      secret        = false
      name          = "RUNNER_SCOPE"
      value         = var.runner_scope
      kv_secret_id  = ""
      keda_metadata = "runnerScope"
    },
    {
      secret        = false
      name          = "REPO_NAME"
      value         = "{project_name}"
      kv_secret_id  = ""
      keda_metadata = "repos"
    },
    {
      secret        = false
      name          = "REPO_URL"
      value         = "https://github.com/${var.organization_name}/{project_name}"
      kv_secret_id  = ""
      keda_metadata = ""
    },
    {
      secret        = false
      name          = "EPHEMERAL"
      value         = true
      kv_secret_id  = ""
      keda_metadata = ""
    },
    {
      secret        = false
      name          = "RANDOM_RUNNER_SUFFIX"
      value         = true
      kv_secret_id  = ""
      keda_metadata = ""
    },
  ]
}
