# GitHub Actions - Workflow Architecture Overview

[English](./GitHub-Actions-Workflow-Architecture.md) | [日本語](./GitHub-Actions-Workflow-Architecture.ja.md)

This document introduces a CI/CD workflow architecture that leverages GitHub Actions, Infrastructure as Code (IaC) with Terraform, and Azure best practices to achieve secure, automated, and auditable provisioning of Azure resources.

The repository for this project provides the DevOps project environment that constitutes this architecture.

## Workflow Architecture Overview

The following diagram illustrates the CI/CD workflow for provisioning Azure resources into a project's Azure subscription using GitHub Actions and Terraform.

The GitHub Actions runner (the execution agent for the CI/CD pipeline) can operate in either a GitHub-hosted environment or as a self-hosted runner built on the customer's Azure environment. The self-hosted runners built on the customer's Azure environment are managed by a container environment (such as Azure Container Apps or Azure Container Instances) provided in the DevOps landing zone within the Azure subscription.

![GitHub Actions Workflow Architecture Overview](/docs/images/github-actions-workflow-architecture.png)

> Figure 1: GitHub Actions Workflow Architecture Overview, showing the flow of Azure resource deployment using Terraform.

### Workflow Components

The repository for this project provisions the following components as the building blocks of the CI/CD workflow:

- **Repository and Branches**
  - The repository is the version control foundation for managing Azure resources as code (IaC = Infrastructure as Code).
  - The repository includes the following branches, with their primary purposes outlined below:

| Branch Name  | Purpose and Role                                                                                                                           |
| :----------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| `features/*` | Feature branches for developing new features or individual changes. Used for local development and testing.                                |
| `dev`        | Branch for the integrated development environment (Development). Integrates multiple `features/*` branches for operational verification.   |
| `staging`    | Branch for the staging environment, which closely mirrors the production environment. Used for final validation before production release. |
| `main`       | Branch containing stable code. Deployments to the production environment are made from this branch.                                        |

- **GitHub Actions Workflow**

  - The CI/CD workflow, powered by GitHub Actions, is triggered by pull requests or direct pushes to each branch (`features/*`, `dev`, `staging`, `main`).
  - GitHub Actions executes processes in stages in response to merges and pushes on each branch as follows:
    - `features/*` → `dev`: `validate` + `plan` triggered by a Pull Request (PR).
    - `dev` push: `plan` + `apply` for automated deployment triggered by a merge commit push.
    - `dev` → `staging`: `validate` + `plan` triggered by a PR.
    - `staging` push: `plan` + `apply` for automated deployment triggered by a merge commit push.
    - `staging` → `main`: `validate` + `plan` triggered by a PR.
    - `main` push: `plan` + `apply` for automated deployment triggered by a merge commit push.
  - **CI Workflow**
    - Terraform `validate` and `plan` jobs are executed upon a pull request (PR) to verify the syntax and integrity of the Terraform IaC code and to preview resource changes.
    - This workflow is designed to be triggered before merges, for example, from `features/*` to `dev`, `dev` to `staging`, and `staging` to `main`.
  - **CI/CD Workflow**
    - Terraform `plan` and `apply` jobs are executed on a push to a branch to confirm the changes in the Terraform IaC code and provision Azure resources accordingly.
    - This workflow functions as a continuous delivery process, automatically deploying Azure resources after a merge commit is integrated into a target branch (such as `dev`, `staging`, or `main`).

- **Jobs and Environments**

  - Each job (`validate`, `plan`, `apply`) runs on a GitHub Runner. GitHub Runners can be either GitHub-hosted or self-hosted (e.g., within an Azure environment).
  - Each environment is defined as a GitHub Actions Environment in the format `env-<project>-main-plan` or `env-<project>-main-apply` and is controlled by appropriate environment variables.
    - The Azure Subscription ID where Azure resources will be provisioned.
    - A user-assigned managed identity with permissions to operate resources within the Azure subscription.

- **Variables**

  - **Repository-Scope Variables**
    - `AZURE_TENANT_ID`: The Azure Tenant ID.
    - `BACKEND_AZURE_RESOURCE_GROUP_NAME`: The resource group name for the Terraform AzureRM backend storage.
    - `BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME`: The container name for the Terraform AzureRM backend storage.
    - `BACKEND_AZURE_STORAGE_ACCOUNT_NAME`: The storage account name for the Terraform AzureRM backend storage.
  - **Environment-Scope Variables**
    - `AZURE_SUBSCRIPTION_ID`: The Azure Subscription ID where Azure resources will be provisioned.
    - `AZURE_CLIENT_ID`: The client ID of the user-assigned managed identity with permissions to operate resources within the Azure subscription.

- **Azure Integration**

  - **Container Platform Management**
    - Provides containerized applications that run as GitHub self-hosted runners.
    - Azure Container App (Job) is an event-driven job execution platform that supports scaling with KEDA.
    - Azure Container Instance provides an always-on runner platform.
  - **ID Management**
    - As a security and access control best practice, different user-assigned managed identities are used for `terraform plan` and `terraform apply`:
      - Managed Identity for `plan`: `Reader` role on the Azure subscription.
      - Managed Identity for `apply`: `Contributor` role on the Azure subscription.

- **Azure Subscription for the Project**
  - A dedicated subscription is required for deploying Azure resources.
  - It is recommended to prepare multiple Azure subscriptions in advance according to the project phases (Development, Development Integration, Staging, Production).
  - Assign the appropriate roles (`Contributor`, `Reader`) to the user-assigned identities for each environment.

## CI/CD Strategy Across Multiple Branches

The following diagram illustrates a robust CI/CD strategy for securely managing and provisioning Azure resources using Terraform IaC, based on the GitHub Actions workflow architecture.

This branching strategy and CI/CD pipeline enables:

- **Clear separation** of development, staging, and production environments.
- **Continuous validation** of code quality.
- A **controlled promotion process**.
- Implementation of **safeguards** to prevent misconfigurations and unauthorized changes.

![CI/CD Workflow Strategy](/docs/images/branch-ci-cd-strategy.png)

> Figure 2: CI/CD Workflow Strategy.

### CI/CD Workflow Scenario

This strategy ensures a safe and managed transition from development to the production environment through the following steps:

1. **Feature Development by Developers**
   - Developers create feature branches, such as `features/F1` and `features/F2`, and push their changes.
   - Developers perform manual testing before pushing changes to the feature branch.
1. **Pull Request to `dev` Branch**
   - A pull request (PR) is created from a feature branch to the `dev` branch.
   - CI automatically runs to check Terraform code syntax and validate the proposed Azure resource changes.
   - Once reviewed and tested, the code is merged into the `dev` branch.
1. **Provisioning to the Development Environment**
   - The merge commit to the `dev` branch triggers a CI/CD pipeline, which automatically applies the Terraform IaC changes to the **Development environment** in Azure.
   - Developers perform operational tests in this environment.
1. **Promotion to the Staging Environment**
   - A PR is created from the `dev` branch to the `staging` branch.
   - After another CI validation, the PR is merged following **manual approval**.
   - The merge commit to the `staging` branch triggers the CI/CD pipeline, automatically provisioning the Terraform IaC changes to the **Staging environment** in Azure.
   - Manual approval is required before provisioning to the **Staging environment**.
1. **Validation in Staging**
   - Tests are conducted in the staging environment for final confirmation before the production release.
   - If issues are found, they are fixed in the `dev` branch and promoted again.
1. **Promotion to the Production Environment**
   - A PR is created from the `staging` branch to the `main` (production) branch.
   - After CI validation, the PR is merged following **manual approval**.
1. **Deployment to the Production Environment**
   - The merge commit to the `main` branch triggers the CI/CD pipeline, automatically provisioning the Terraform IaC changes to the **Production environment** in Azure.
   - Manual approval is required before provisioning to the **Production environment**.

### Branch Structure

The main branches used in this strategy are as follows:

- **`features/*` Branches (For developer work)**
  - Created for each new feature or fix (e.g., `features/F1`).
  - Merged into the `dev` branch via a PR after passing CI validation.
- **`dev` Branch (Development Environment)**
  - The integration point for all `features/*` branches.
  - After a merge, changes are provisioned to the Azure **Development environment** via Terraform `plan` / `apply`.
- **`staging` Branch (Staging Environment)**
  - Receives changes from `dev` via a PR, which is merged after **manual approval**.
  - CI/CD applies changes to the Azure **Staging environment**.
  - An additional **manual approval** is enforced before provisioning.
- **`main` Branch (Production Environment)**
  - Only changes from `staging` can be merged via a PR.
  - Merged after CI validation and **manual approval**, reflecting the changes in the production environment.
  - A final **manual approval** is also required before provisioning.

### Promotion and Approval Flow

- **PR (Pull Request) and Code Review**
  - Code reviews and CI validation occur at each stage: `features/*` → `dev`, `dev` → `staging`, and `staging` → `main`.
  - Promotions to the `staging` and `main` branches require **manual approval**, strengthening governance.
- **Implementation of Manual Approval**
  - **Manual approval for PRs** is provisioned as a rule using the `Required Reviewers` feature in GitHub's branch rulesets.
  - **Manual approval for provisioning** is achieved by provisioning a GitHub Environment that uses the `Required Reviewers` feature.
- **Environment Separation**
  - Each branch corresponds to a specific Azure environment: Development, Staging, or Production.
  - Terraform state files and credentials are managed separately for each environment to eliminate cross-environmental impact.
- **Guardrails via Manual Approval**
  - Requiring human approval at critical promotion points and before Azure resource provisioning ensures security and compliance.

### Security and Best Practices

- **Principle of Least Privilege**
  - Each environment uses a dedicated Azure user-assigned managed identity with only the necessary permissions.
  - By using different Azure user-assigned managed identities and GitHub Environments for `terraform plan` and `terraform apply`, the workflow enforces separation of duties and minimizes risk.
  - The use of Azure user-assigned managed identities from GitHub Environments is configured with [workload identity federation using OIDC](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure), enabling secure identity operations based on the principle of least privilege.
  - Manual approvals and code reviews prevent unauthorized or accidental changes.
- **State Management**
  - Terraform state is securely stored in Azure Storage, with access controlled by user-assigned managed identities.
  - Access to the Terraform state file is exclusively controlled using Azure Storage's state lock (Blob Lease) feature, and `concurrency` is set in the GitHub Actions workflow. This prevents conflicts from concurrent `terraform apply` executions and ensures safe management.
- **Auditing and Traceability**
  - All actions (CI/CD executions, approvals, merges) are logged in GitHub and Azure Log Analytics, providing a complete audit trail for compliance and troubleshooting.
- **Automated Testing**
  - The CI pipeline runs automated tests and Terraform validation at every stage to detect issues early.

## Future Updates to Consider

- **Support for Drift Detection**
  - Add a mechanism to the CI process that periodically schedules `terraform plan` to detect drift, thereby achieving continuous validation.
- **Handling Rollbacks during Staging-to-Production Promotion**
  - Establish a process for detecting incidents in the production environment.
  - Create and manage a recovery branch for state rollback.
  - Conduct confirmation tests and merge back to the production branch.
