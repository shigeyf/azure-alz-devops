# DevOps Lnading Zone for Azure Resources Deployment

[English](./README.md) | [日本語](./README.ja.md)

<a id="overview"></a>

## Overview

This repository provides a comprehensive, modular infrastructure-as-code solution for deploying and managing Azure resources with using Terraform and CI/CD workflows. This is designed to support both Azure DevOps and GitHub-based CI/CD workflows, enabling organizations to automate the provisioning of secure, scalable, and policy-compliant cloud environments using infrastructure as code, versioned with Git.

Key features include:

- **Modular Terraform Architecture**: Reusable modules for common Azure and DevOps patterns.
- **Support for Azure DevOps and GitHub**: Provisioning of projects, repositories, pipelines, and self-hosted agents/runners.
- **Secure State and Secret Management**: Uses Azure Storage and Key Vault for managing Terraform state and sensitive information.
- **Enterprise-Ready**: Implements best practices for secure closed network, identity, and repository policy enforcement for deployment task executions.
- **Extensible and Customizable**: Easily adaptable to various organizational requirements and cloud governance models.

The `infra/terraform` directory contains all core infrastructure code, organized for clarity and scalability. This structure allows teams to bootstrap foundational resources, deploy landing zones, and manage project-specific DevOps resources in a consistent and automated manner.

> [!NOTE]
> Currently we only support GitHub projects.
>
> We are planning to support Azure DevOps projects in the near future.

<a id="getting-started"></a>

## Getting Started

To provision DevOps CI/CD environment that automates the deployment of Azure resources, please perform the following steps after making the necessary preparations for each of steps.

<a id="start-0-prerequisites"></a>

### 0. Prerequisites

Please prepare the following components and permissions:

- Azure CLI
- Entra ID tenant to manage Azure Subscriptions
- Azure Subscriptions (total of 5)
  - Azure Subscriptions to deploy DevOps resources
  - Azure Subscriptions to be used in the project (4)
    - Subscriptions used by developers for feature development work
    - Subscriptions for development
    - Subscriptions for staging
    - Subscriptions for production deployment
- `Owners` or `Contributors` permissions for the above Azure Subscriptions
  - Permissions for the user who will be using this document
- GitHub PAT (Personal Access Token)
  - Token for provisioning GitHub project resources (token with the following permissions)
    - `repo`
    - `workflow`
    - `admin:org`
    - `user: read:user`
    - `user: user:email`
    - `delete_repo`
  - Token for GitHub self-hosted runner
    - `repo`
    - `admin:org`

> [!NOTE]
> All Azure Subscriptions must be prepared under the same Entra ID tenant.

> [!NOTE]
> The above explanation about GitHub PAT refer to `classic` personal access tokens. You can also use `fine-grained` access tokens which are still in beta to provide more granular permissions. These docs will be updated to reflect this in the future.

Please log in to your Entra ID using Azure CLI.

```bash
az login --tenant <Tenant_Id>
```

<a id="start-1-provision-bootstrap"></a>

### 1. Provisioning Bootstrap Resources

Please use the bootstrap module ([`infra/terraform/_bootstrap`](./infra/terraform/_bootstrap/) to provision the foundation resources (Azure Blob Storage and Key Vault) for the DevOps environment.

```bash
cd $ProjectRoot/infra/terraform/_bootstrap
```

<a id="start-1-provision-bootstrap-1a"></a>

#### 1-a. Preparing your parameters file

For provisioning the bootstrap resources, refer to the sample parameters file ([`infra/terraform/_bootstrap/terraform.tfvars.sample`](./infra/terraform/_bootstrap/terraform.tfvars.sample)).

```bash
cp terraform.tfvars.sample terraform.tfvars
```

The following parameters can be specified:

<a id="start-1-provision-bootstrap-parameters"></a>

| Parameter                             | Type         | Optional | Description                                                                                                                    |
| ------------------------------------- | ------------ | -------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `target_subscription_id`              | string       | No       | Azure subscription Id for deploying DevOps Landing Zone (bootstrap resources)                                                  |
| `naming_suffix`                       | list(string) | Yes      | Suffix for resource naming (default: `["alz", "devops", "bootstrap"]`)                                                         |
| `location`                            | string       | No       | Location in where DevOps resources are deployed                                                                                |
| `tags`                                | map(string)  | Yes      | Resource tags (default: `{}` [empty map])                                                                                      |
| `tfstate_container_name`              | string       | Yes      | Blob container name for Terraform state files (`*.tfstate`) for Bootstrap and DevOps resources (default: `tfstate`)            |
| `enable_user_assigned_identity`       | bool         | Yes      | Whether to enable user-assigned identity for Bootstrap resources (default: `false`)                                            |
| `enable_storage_customer_managed_key` | bool         | Yes      | Whether to enable customer-managed keys (CMK) for Blob Storage (tfstate) (default: `true`)                                     |
| `customer_managed_key_policy`         | object       | Yes      | Policy for customer-managed key (default: RSA 4096 bit, require renewal in 90 days)                                            |
| `bootstrap_config_filename`           | string       | Yes      | Filename to save bootstrap config file (default: `./bootstrap.config.json`)                                                    |
| `tfbackend_config_template_filename`  | string       | Yes      | Template configurations of azurerm remote backend for Terraform state management files (default: `./devops.azurerm.tfbackend`) |

<a id="start-1-provision-bootstrap-1b"></a>

#### 1-b. Run Bootstrap Resource Provisioning

Run Terraform for Bootstrap resource provisioning.

First, you will manage the Terraform state management file locally.

```bash
terraform init
terraform plan
terraform apply
```

After the provisioning above is complete, the following files will be generated.

- `backend.tf`
- `bootstrap.config.json` (or the file name specified in `bootstrap_config_filename`)
- `devops.azurerm.tfbackend` (or the file name specified in `tfbackend_config_template_filename`)

These files store the configuration information for the bootstrap resources and will be used in the next step.

<a id="start-1-provision-bootstrap-1c"></a>

#### 1-c. Migrate Terraform state management file

You can also manage the Terraform state management file for this bootstrap resource provisioning itself in the azurerm remote backend by running the following command:

```bash
terraform init -migrate-state
```

<a id="start-2-provision-devops-lz"></a>

### 2. Provisioning DevOps Landing Zone Resources

After the Bootstrap resource provisioning above is complete, the next step is to provision the DevOps Landing Zone resources.

```bash
cd $ProjectRoot/infra/terraform/devops/lz
```

<a id="start-2-provision-devops-lz-2a"></a>

#### 2-a. Prepare your parameters file

For provisioning the DevOps Landing Zone resources, refer to the sample parameters file ([`infra/terraform/devops/lz/terraform.tfvars.sample`](./infra/terraform/devops/lz/terraform.tfvars.sample)).

```bash
cp terraform.tfvars.sample terraform.tfvars
```

> [!NOTE]
> In this step, you will use provisioned Bootstrap resources, so be sure to specify the JSON file (specified in the parameter `bootstrap_config_filename`) that contains the configuration information of the bootstrap resources. If you are using the default value in the previous step, there is no need to change the parameter in this step.

The parameters that can be specified are as follows.

<a id="start-2-provision-devops-lz-parameters"></a>

| Parameter                                       | Type         | Optional | Description                                                                                              |
| ----------------------------------------------- | ------------ | -------- | -------------------------------------------------------------------------------------------------------- |
| `target_subscription_id`                        | string       | No       | Azure Subscription Id for deploying DevOps Landing Zone (DevOps landing zone resources)                  |
| `naming_suffix`                                 | list(string) | Yes      | Suffix for resource naming (default: `["alz", "devops"]`)                                                |
| `location`                                      | string       | No       | Location in where DevOps resources are deployed                                                          |
| `tags`                                          | map(string)  | Yes      | Resource tags (default: `{}` [empty map])                                                                |
| `enable_self_hosted_agents`                     | bool         | Yes      | Whether to enable self-hosted agents/runners (default: `true`)                                           |
| `enable_private_network`                        | bool         | Yes      | Whether to enable the private virtual network where the self-hosted agents/runners run (default: `true`) |
| `enable_github`                                 | bool         | Yes      | Whether to enable GitHub for this DevOps resource (default: `true`)                                      |
| `github_organization_name`                      | string       | No       | GitHub organization name                                                                                 |
| `github_personal_access_token`                  | string       | No       | GitHub personal access token to be used for provisioning GitHub resources                                |
| `github_personal_access_token_for_runners`      | string       | No       | GitHub personal access token to be used for GitHub self-hosted runners                                   |
| `vnet_address_prefix`                           | string       | No       | Virtual network address prefix for the private virtual network                                           |
| `vnet_private_endpoint_subnet_address_prefix`   | string       | No       | Private endpoint subnet address prefix for the private virtual network                                   |
| `vnet_gateway_subnet_address_prefix`            | string       | No       | Gateway subnet address prefix for the private virtual network                                            |
| `vnet_container_app_subnet_address_prefix`      | string       | No       | ACA subnet address prefix for the private virtual network                                                |
| `vnet_container_instance_subnet_address_prefix` | string       | No       | ACI subnet address prefix for the private virtual network                                                |
| `vnet_private_endpoint_subnet_name`             | string       | Yes      | Private endpoint subnet name for the private virtual network (default: `private-endpoints`)              |
| `vnet_container_app_subnet_name`                | string       | Yes      | ACA subnet name for the private virtual network (default: `container-apps`)                              |
| `vnet_container_instance_subnet_name`           | string       | Yes      | ACI subnet name for the private virtual network (default: `container-instances`)                         |
| `enable_agents_environment_zone_redundancy`     | bool         | Yes      | Whether to enable zone redundancy for ACA (default: `true`)                                              |
| `bootstrap_config_filename`                     | string       | Yes      | Filename to load bootstrap config file to (default: `../../_bootstrap/bootstrap.config.json`)            |

<a id="start-2-provision-devops-lz-2b"></a>

#### 2-b. Run DevOps Resource Provisioning

Run Terraform for DevOps resource provisioning.

You will manage the Terraform state file with the azurerm remote backend with using template configurations of Terraform azurerm remote backend.

```bash
terraform init -backend-config ../../_bootstrap/devops.azurerm.tfbackend -backend-config key=devopslz.terraform.tfstate
terraform plan
terraform apply
```

<a id="start-3-provision-devops-project"></a>

### 3. Provisioning DevOps Project Resources

After the DevOps Landing Zone resources provisioning above is complete, the next step is to provision individual resources for each project (Git repositories, CI/CD pipelines, user-assigned identities, environments for running containers for self-hosted agents/runners, and so on).

This step can be run on a per-project basis, using the shared resources in the DevOps Landing Zone provisioned in the previous step.

```bash
cd $ProjectRoot/infra/terraform/devops/project_github
export project_name="<your-project-name>"
```

> [!NOTE]
> Currently we only support GitHub projects.
>
> We are planning to support Azure DevOps projects in the future.

<a id="start-3-provision-devops-project-3a"></a>

#### 3-a. Prepare parameters file

For provisioning project resources, please refer to the sample parameters file ([`infra/terraform/devops/project_github/terraform.tfvars.sample`](./infra/terraform/devops/project_github/terraform.tfvars.sample)).

```bash
cp terraform.tfvars.sample terraform.tfvars
```

> [!NOTE]
> In this step, you will use provisioned Bootstrap resources, so be sure to specify the JSON file (specified in the parameter `bootstrap_config_filename`) that contains the configuration information of the bootstrap resources. If you are using the default value in the previous step, there is no need to change the parameter in this step.

> [!NOTE]
> In this step, you will use the provisioned DevOps Landing Zone resources, so you will use the Terraform state management file which was generated when provisioning the DevOps Landing Zone resources. For this reason, be sure to specify in the `devops_tfstate_key` parameter the `key` parameter of the azurerm remote backend specified in the provisioning execution command in step 2. If you are executing as specified in this document, there is no problem with the default value.

The parameters that can be specified are as follows.

<a id="start-3-provision-devops-project-parameters"></a>

| Parameter                   | Type        | Optional | Description                                                                                                                                |
| --------------------------- | ----------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `target_subscription_id`    | string      | No       | Azure Subscription Id for provisioning DevOps Project resources                                                                            |
| `project_name`              | string      | No       | Project name                                                                                                                               |
| `location`                  | string      | No       | Location in where DevOps resources are deployed                                                                                            |
| `tags`                      | map(string) | Yes      | Resource tags (default: `{}` [empty map])                                                                                                  |
| `subscriptions`             | map(object) | No       | A map type list of Azure Subscriptions to be used in the DevOps Project                                                                    |
| `use_templates_repository`  | bool        | Yes      | Whether to use a template repository with your DevOps Project (default: `true`)                                                            |
| `use_runner_group`          | bool        | Yes      | Whether to use GitHub Runner Group with your DevOps Project (default: `false`)                                                             |
| `use_self_hosted_runners`   | bool        | Yes      | Whether to use GitHub Self-Hosted Runners in your DevOps project (default: `true`)                                                         |
| `self_hosted_runners_type`  | string      | Yes      | Compute type of GitHub Self-Hosted Runners (Options: "aca" or "aci") (default: `aca`)                                                      |
| `bootstrap_config_filename` | string      | Yes      | Filename to load bootstrap config file to (default: `../../_bootstrap/bootstrap.config.json`)                                              |
| `devops_tfstate_key`        | string      | Yes      | Terraform state management filename for DevOps Landing Zone resources (azurerm remote backend key) (default: `devopslz.terraform.tfstate`) |

<a id="start-3-provision-devops-project-3b"></a>

#### 3-b. Run DevOps Project Resource Provisioning

Run Terraform to run DevOps Project resource provisioning.

You will manage the Terraform state file with the azurerm remote backend with using template configurations of Terraform azurerm remote backend.

```bash
terraform init -backend-config ../../_bootstrap/devops.azurerm.tfbackend -backend-config key=${project_name}.terraform.tfstate
terraform plan
terraform apply
```

<a id="contributing"></a>

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any suggestions or improvements.
