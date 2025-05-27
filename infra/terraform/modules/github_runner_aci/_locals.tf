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
  rand_id           = random_string.random.result
  runner_name       = "runner-{project_name}-${local.rand_id}"
  runner_group_name = "default-{project_name}-${local.rand_id}"
}
