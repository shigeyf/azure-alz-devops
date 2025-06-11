// _locals.tf

locals {
  github_access_token_secret_name = element(reverse(split("/", var.runner_pat_secret_id)), 0)
}
