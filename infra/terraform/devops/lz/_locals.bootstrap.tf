// _locals.bootstrap.tf

locals {
  bootstrap = jsondecode(file(var.bootstrap_config_filename))
}
