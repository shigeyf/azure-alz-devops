# DevOps Landing Zone for Azure Resources Terraform CI/CD deployment

[English](./README.md) | [日本語](./README.ja.md)

---

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
  - [0\. Prerequisites](#start-0-prerequisites)
  - [1\. Provisioning Bootstrap Resources](#start-1-provision-bootstrap)
  - [2\. Provisioning DevOps Landing Zone Resources](#start-2-provision-devops-lz)
  - [3\. Provisioning DevOps Project Resources](#start-3-provision-devops-project)
- [Example of provisioned resources](#example-output)
- [Contents of this repository](#contents)
- [Technical Details](#tech-details)
  - [GitHub Actions Workflow Architecture](#tech-details-github-actions-workflow-arch)
- [Acknowledgements](#acknowledgements)
- [Contributing](#contributing)

---

<a id="overview"></a>

## Overview

This repository provides a comprehensive, modular infrastructure-as-code solution for deploying and managing Azure resources with using Terraform and CI/CD workflows. This is designed to support both Azure DevOps and GitHub-based CI/CD workflows, enabling organizations to automate the provisioning of secure, scalable, and policy-compliant cloud environments using infrastructure as code, versioned with Git.
The project Git repository which is provisined by this module is designed to be used in enterprise environments and follows Azure and Terraform best practices.

![High-level DevOps Landing Zone Architecture Overview](/docs/images/devops-landing-zone-architecture.png)

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

## Azure Architecture

The architecture including Azure network is shown in the diagram below. This diagram shows a configuration where a private virtual network is enabled and a GitHub self-hosted runners are hosted in Azure Container App jobs and execute CI/CD workflow jobs in an event-driven manner using KEDA scaling.

It also shows a configuration where a project for a Microsoft Dev Box is deployed so that developers can work for Azure projects using a secure development environment. The Dev Box virtual desktop is connected to a private virtual network, so it can securely access Terraform state management files and deploy and manage Azure resources.

![Azure Architecture of DevOps Landing Zone](./docs/images/devops-landing-zone-azure-network-architecture-with-aca.png)

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

> [!NOTE]
> Please register a list of resource providers for all subscriptions you have prepared.
>
> The Terraform IaC code prepared in this repository requires that you need to register the necessary resource providers in advance. Also, in your future Azure projects, it may cause an error when running `terraform plan` with the allocated user-assigned identity.
>
> To register resource providers, you can use the script in the following folder to register the specified resource providers in bulk.
>
> ```bash
> cd $ProjectRoot/infra/terraform/_setup_subscriptions
> ./register_rps.sh -s <your_subscription_id>
> ```

<a id="start-1-provision-bootstrap"></a>

### 1. Provisioning Bootstrap Resources

![Provisioning Bootstrap Resources](/docs/images/provisioned-bootstrap-resources.png)

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

![Provisioning DevOps Landing Zone Resources](/docs/images/provisioned-devops-resources.png)

After the Bootstrap resource provisioning above is complete, the next step is to provision the DevOps Landing Zone resources.

```bash
cd $ProjectRoot/infra/terraform/devops/lz
```

<a id="start-2-provision-devops-lz-2a"></a>

#### 2-a. Prepare your parameters file

For provisioning the DevOps Landing Zone resources, refer to the sample parameters file ([`infra/terraform/devops/lz/terraform.tfvars.sample`](./infra/terraform/devops/lz/terraform.tfvars.sample)).

> [!NOTE]
>
> All sensitive values (such as PATs) which are used in this step are managed in Bootstrap's Azure Key Vault.

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

![Provisioning DevOps Project Resources](/docs/images/provisioned-devops-project-resources.png)

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

<a id="example-output"></a>

## Example of provisioned resources

[The document](./docs/Example-of-DevOps-Landing-Zone.md) explaines an example of provisioned resources.

<a id="contents"></a>

## Contents of this repository

<a id="contents-dir-structure"></a>

### Directory Structure

```text
infra/
└── terraform/
    ├── _bootstrap/
    ├── _setup_subscriptions/
    ├── devops/
    │   ├── lz/
    │   └── project_github/
    └── modules/
```

<a id="contents-bootstrap"></a>

### 1. Bootstrap Resource module (`infra/terraform/_bootstrap/`)

This folder contains Terraform code and configuration files for bootstrapping the foundational Azure resources required for state management and secure secret storage, such as:

- Storage accounts for Terraform state
- Key Vaults for secrets

<a id="contents-devops"></a>

### 2. DevOps Resource module (`infra/terraform/devops/`)

This folder contains environment-specific and project-specific Terraform configurations for provisioning DevOps resources. Key subfolders include:

- `lz/`: Landing Zone resources, including networking, identity, and self-hosted agents/runners infrastructure for both Azure DevOps and GitHub Actions.
- `project_github/`: Project-level resources for GitHub-based CI/CD, including repository, runner, and workflow setup.

<a id="contents-reusable-modules"></a>

### 3. `modules/`

A collection of reusable Terraform modules for common infrastructure patterns, including:

- `aca_env/`, `aca_event_job/`, `aca_manual_job/`: Modules for Azure Container Apps environments and jobs.
- `aci/`: Azure Container Instances.
- `azure_devops/`, `azure_devops_agent_aca/`, `azure_devops_agent_aci/`, `azure_devops_pipelines/`: Modules for Azure DevOps projects, agents, and pipelines.
- `github/`, `github_runner_aca/`, `github_runner_aci/`, `github_workflows/`: Modules for GitHub repositories, self-hosted runners (on ACA/ACI), and workflow automation.
- `resource_providers/`: Registration and management of Azure resource providers.

> [!NOTE]
> Terraform `azurerm_resource_provider_registration` does not provide a module for loading already registered Azure resource providers. Registration and un-registration of the Azure resource providers are likely conflicting between multiple Terraform project deployments, and Terraform state management for resource providers is also difficult, so it should not be used.

<a id="tech-details"></a>

## Technical Details

<a id="tech-details-github-actions-workflow-arch"></a>

### GitHub Actions Workflow Architecture

[This document](./docs/GitHub-Actions-Workflow-Architecture.md) provides technical details about the workflow architecture using GitHub Actions that is provisioned in this project repository.

<a id="acknowledgements"></a>

## Acknowledgements

This project is insipred by the [Azure Landing Zone Accelerator](https://github.com/Azure/alz-terraform-accelerator) project. The [Azure Landing Zone Accelerator](https://github.com/Azure/alz-terraform-accelerator) project is focusing on the DevOps resources only for Azure Landing Zone deployment, while this project is focusing on a generic Azure deployment project. Thanks to [Jared Holgate](https://github.com/jaredfholgate) and contributors and team members of [Azure Landing Zone Accelerator](https://github.com/Azure/alz-terraform-accelerator) project.

<a id="contributing"></a>

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any suggestions or improvements.
