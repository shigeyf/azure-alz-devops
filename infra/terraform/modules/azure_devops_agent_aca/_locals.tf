// _locals.tf

locals {
  rand_len = 4
}

// Generate a random string for the naming identifier
resource "random_string" "random" {
  length  = local.rand_len
  numeric = true
  lower   = true
  upper   = false
  special = false
}

locals {
  rand_id             = random_string.random.result
  require_placeholder = true
  agent_name          = "agent-{project_name}-${local.rand_id}"
  placeholder_name    = "placeholder-{project_name}-${local.rand_id}"
  agent_pool_name     = "default-{project_name}-${local.rand_id}"
}

locals {
  azp_url_secret_name   = element(reverse(split("/", var.organization_url_secret_id)), 0)
  azp_token_secret_name = element(reverse(split("/", var.agent_pat_secret_id)), 0)
}
