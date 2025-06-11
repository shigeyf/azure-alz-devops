// _locals.tf

locals {
  runner_name       = "runner-{project_name}-{random}"
  runner_group_name = "{runner_group_name}"
}

locals {
  github_access_token_secret_name = element(reverse(split("/", var.runner_pat_secret_id)), 0)
}
