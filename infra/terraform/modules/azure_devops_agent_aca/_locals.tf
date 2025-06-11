// _locals.tf

locals {
  require_placeholder = true
  agent_name          = "agent-{project_name}-{random}"
  placeholder_name    = "placeholder-{project_name}-{random}"
  agent_pool_name     = "default-{project_name}-{random}"
}

locals {
  azp_url_secret_name   = element(reverse(split("/", var.organization_url_secret_id)), 0)
  azp_token_secret_name = element(reverse(split("/", var.agent_pat_secret_id)), 0)
}
