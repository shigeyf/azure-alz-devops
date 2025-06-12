// _locals.tf

locals {
  require_placeholder   = true
  azp_url_secret_name   = element(reverse(split("/", var.organization_url_secret_id)), 0)
  azp_token_secret_name = element(reverse(split("/", var.agent_pat_secret_id)), 0)
}
