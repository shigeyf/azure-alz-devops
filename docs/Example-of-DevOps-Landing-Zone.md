# Provisioned DevOps Resource Example

[English](./Example-of-DevOps-Landing-Zone.md) | [日本語](./Example-of-DevOps-Landing-Zone.ja.md)

This document shows an example of provisioned resources by this project repository.

## Provisioned Resource Groups

This example has the following generated resource groups:

- [Bootstrap resources](#provisioned-bootstrap-resources): rg-alz-devops-bootstrap-jpe-yxci
- [Identity resources](#provisioned-identity-resources): rg-alz-devops-identity-jpe-068e
- [Agents resources](#provisioned-agents-resources): rg-alz-devops-agents-jpe-068e
- [Network resources](#provisioned-network-resources): rg-alz-devops-network-jpe-068e

![Resource Groups](/docs/images/provisioned-resources-example-1-rg.png)

## Provisioned Bootstrap resources

This resource group contains:

- **Key Vault**: storing Customer-managed Keys (CMK) and GitHub PAT Secrets
- **Storage (Blob)**: storing Terraform State files for both this DevOps Landing Zone resource deployment and project resource deployment, and project CI/CD log data.

![Bootstrap Resources](/docs/images/provisioned-resources-example-2-bootstrap.png)

## Provisioned Identity resources

This resource group contains 7 **User-assigned Managed Identities**:

1. Identity for Terraform CI/CD (`plan`) to **Features** development Azure subscription environment (for developers)
1. Identity for Terraform CI (`plan`) to **Development** Azure subscription environment
1. Identity for Terraform CI/CD (`apply`) to **Development** Azure subscription environment
1. Identity for Terraform CI (`plan`) to **Staging** Azure subscription environment
1. Identity for Terraform CI/CD (`apply`) to **Staging** Azure subscription environment
1. Identity for Terraform CI (`plan`) to **Production** Azure subscription environment
1. Identity for Terraform CI/CD (`apply`) to **Production** Azure subscription environment

![DevOps Landing Zone Identity Resources](/docs/images/provisioned-resources-example-3-devops-identity.png)

## Provisioned Agents resources

This resource group contains the following resources:

- **Container Registry (ACR)**: managing container images of GitHub Runners
- **Container App (ACA) Environment**
- **Log Analytics Workspace**: managing logs for container applications
- **User-assigned Managed Identity**: managing identity for secret data access (stored in Key Vault) and for pulling container images from Container Registry (ACR)

> [!NOTE]
> Container App Environment resource is generated when using both ACA and ACI as commonn resources for multiple projects. This resource itself will not incur any cost.

When using ACA:

- **Container App (ACA) Job**: event-Triggered job with hosting Self-Hosted GitHub Runners

When of using ACI:

- multiple **Container Instances (ACI)**: multiple instance hosting Self-Hosted GitHub Runners

![DevOps Landing Zone Agents Resources ACA)](/docs/images/provisioned-resources-example-4-devops-agents1.png)

![DevOps Landing Zone Agents Resources (ACI)](/docs/images/provisioned-resources-example-6-devops-agents3.png)

If you will enable private network for DevOps Landing Zone, you will see the extra resource group containing auto-generated network resources for Container App Environemnt.

![DevOps Landing Zone Agents Resources (CAE)](/docs/images/provisioned-resources-example-5-devops-agents2.png)

## Provisioned Network resources

This resource group contains:

- **Virtual Network** with the following subnets
  - A subnet for private endpoint resources (`snet-private-endpoints`)
  - A subnet for Gateway (`GatewaySubnet`): network traffic egress will be through NAT Gateway
  - A subnet for Container App Environment (`snet-container-apps`)
  - A subnet for Container Instances (`snet-container-instances`)
- **Network Security Groups** for each of subnets (excluding Gateway subnet)
- **NAT Gateway**
- **Public IP Address**: used for outbound traffic via NAT Gateway
- **Private Endpoints**
  - For Blob Storage
  - For Key Vault
  - For Container Registry
- **Private DNS Zones**: associated with the Virtual Network above
  - For Blob Storage
  - For Key Vault
  - For Container Registry

![DevOps Landing Zone Network Resources](/docs/images/provisioned-resources-example-7-devops-network.png)
