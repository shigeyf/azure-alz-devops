// _variables.tf

variable "organization_url_secret_id" {
  description = "Azure DevOps Organization URL secret Id"
  type        = string
}

variable "agent_pat_secret_id" {
  description = "Azure DevOps Agent PAT (Personal Access Token) secret Id"
  type        = string
}

variable "secret_reader_uami_id" {
  description = "User-assigned Managed Identity Id to read Key Vault secrets"
  type        = string
}

variable "container_cpu" {
  description = "CPU allocation for the container image"
  type        = string
  default     = "1.0"
}

variable "container_memory" {
  description = "Memory allocation for the container image"
  type        = string
  default     = "2"
}

variable "container_platform_os" {
  description = "Platform OS for the container image"
  type        = string
  default     = "Linux"
}

variable "container_image_name" {
  description = "Contaienr image name in the registry"
  type        = string
  default     = "azuredevops-agent-aca"
}

variable "container_src_repo_url" {
  description = "Repositoy URL for building the container image"
  type        = string
  default     = "https://github.com/Azure/avm-container-images-cicd-agents-and-runners"
}

variable "container_src_repo_tag" {
  description = "Tag of the repositoy for building the container image"
  type        = string
  default     = "bc4087f"
}

variable "container_src_docker_root" {
  description = "Root path in the repository for building the container image"
  type        = string
  default     = "azure-devops-agent-aca"
}

variable "container_src_docker_file" {
  description = "Docker file for building the container image"
  type        = string
  default     = "dockerfile"
}

variable "acr_login_server" {
  description = "Azure Container Registry login server"
  type        = string
}
