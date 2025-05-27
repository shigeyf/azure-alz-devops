// _locals.env.tf

/*
Container Image for Azure DevOps Self-Hosted CI/CD Agent
https://github.com/Azure/avm-container-images-cicd-agents-and-runners

| Name                  | Description                                                                 |
| --------------------- | --------------------------------------------------------------------------- |
| AZP_URL               | String for Azure DevOps organization (https://dev.azure.com/<organization>) |
| AZP_TOKEN             | String for Personal Access Token                                            |
| AZP_POOL              | Steing Agent Pool Name                                                      |
| AZP_AGENT_NAME        | String Agent Name                                                           |
| AZP_WORK              | String Agent working directory [optional]                                   |
*/

locals {
  environment_variables = [
    {
      secret = true
      name   = "AZP_URL"
      value  = var.organization_url_secret_id
    },
    {
      secret = true
      name   = "AZP_TOKEN"
      value  = var.agent_pat_secret_id
    },
    {
      secret = false
      name   = "AZP_POOL"
      value  = local.agent_pool_name
    },
    {
      secret = false
      name   = "AZP_AGENT_NAME"
      value  = local.agent_name
    },
  ]
}
