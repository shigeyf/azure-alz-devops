// resource_provider.tf

# locals {
#   is_windows = substr(pathexpand("~"), 0, 1) == "C" ? true : false
#   _required_resource_providers = concat(
#     var.required_resource_providers,
#     var.enable_extended_resource_providers ? var.required_resource_providers_extended : [],
#     var.enable_all_resource_providers ? var.required_resource_providers_all : [],
#   )
# }

# resource "null_resource" "resource_providers_windows" {
#   for_each = local.is_windows ? toset(local._required_resource_providers) : []
#
#   provisioner "local-exec" {
#     interpreter = ["powershell", "-Command"]
#     command     = <<EOT
#     az account set --subscription ${var.subscription_id}
#     $state = (az provider show --namespace ${each.key} --query "registrationState" -o tsv)
#     if ($state -ne "Registered") {
#       Write-Host "Registering a Resource Provider ${each.key}..."
#       az provider register --namespace ${each.key} --wait
#     } else {
#       Write-Host "Resource provider ${each.key} is already registered."
#     }
#     EOT
#   }
#
#   triggers = {
#     always_run = timestamp()
#   }
# }

# resource "null_resource" "resource_providers_unix" {
#   for_each = local.is_windows ? [] : toset(local._required_resource_providers)
#
#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     command     = <<EOT
#     az account set --subscription ${var.subscription_id}
#     state=$(az provider show --namespace ${each.key} --query "registrationState" -o tsv)
#     if [ "$state" != "Registered" ]; then
#       echo "Registering a Resource Provider ${each.key}..."
#       az provider register --namespace ${each.key} --wait
#     else
#       echo "Resource provider ${each.key} is already registered."
#     fi
#     EOT
#   }
#
#   triggers = {
#     always_run = timestamp()
#   }
# }
