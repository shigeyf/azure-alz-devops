// _locals.env.tf

/*
Container Image for Azure DevOps Self-Hosted CI/CD Agent
https://github.com/Azure/avm-container-images-cicd-agents-and-runners

| Name                  | Description                                                                 |
| --------------------- | --------------------------------------------------------------------------- |
| AZP_URL               | String for Azure DevOps organization (https://dev.azure.com/<organization>) |
| AZP_TOKEN             | String for Personal Access Token                                            |
| AZP_POOL              | Steing Agent Pool Name                                                      |
| AZP_AGENT_NAME_PREFIX | String Agent name prefix                                                    |
| AZP_AGENT_NAME        | String Agent Name (used for placeholder)                                    |
| AZP_PLACEHOLDER       | Bool   Whether placeholder agent or not                                     |
| AZP_WORK              | String Agent working directory [optional]                                   |
*/

locals {
  environment_variables = [
    {
      secret        = true
      name          = "AZP_URL"
      value         = local.azp_url_secret_name
      kv_secret_id  = var.organization_url_secret_id
      keda_metadata = "organizationURL"
    },
    {
      secret        = true
      name          = "AZP_TOKEN"
      value         = local.azp_token_secret_name
      kv_secret_id  = var.agent_pat_secret_id
      keda_metadata = "personalAccessToken"
    },
    {
      secret        = false
      name          = "AZP_POOL"
      value         = "default-pool-{project_name}-{random}"
      kv_secret_id  = ""
      keda_metadata = "poolName"
    },
    {
      secret        = false
      name          = "AZP_AGENT_NAME_PREFIX"
      value         = "agent-{project_name}-{random}"
      kv_secret_id  = ""
      keda_metadata = ""
    }
  ]

  placeholder_environment_variables = [
    {
      secret        = false
      name          = "AZP_AGENT_NAME"
      value         = "placeholder-{project_name}-{random}"
      kv_secret_id  = ""
      keda_metadata = ""
    },
    {
      secret        = false
      name          = "AZP_PLACEHOLDER"
      value         = "true"
      kv_secret_id  = ""
      keda_metadata = ""
    }
  ]
}
