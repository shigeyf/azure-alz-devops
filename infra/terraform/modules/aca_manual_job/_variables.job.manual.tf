// _variables.job.manual.tf

variable "manual_jobs" {
  type = list(
    object({
      manual_job_name                 = string
      replica_timeout                 = optional(number, 300)
      replica_retry_limit             = optional(number, 0)
      manual_parallelism              = optional(number, 1)
      manual_replica_completion_count = optional(number, 1)
      workload_profile_name           = optional(string, null)
      template = object({
        container = set(object({
          name   = string
          cpu    = string
          memory = string
          image  = string
          env = optional(set(
            object({
              name        = string
              value       = optional(string, null)
              secret_name = optional(string, null)
            })
          ), [])
        }))
      })
      registry = optional(set(
        object({
          server   = optional(string, null)
          identity = optional(string, null)
        })
      ), [])
      secret = optional(set(
        object({
          name                = string
          identity            = optional(string, null)
          key_vault_secret_id = optional(string, null)
          value               = optional(string, null)
        })
      ), [])
    })
  )
  description = "List of manual jobs to be created"
  sensitive   = true
  default     = []
}

//
// Sample Job Configuration with Azure CLI (for reference only):
// --trigger-type Manual
// --replica-timeout 300
// --replica-retry-limit 0
// --replica-completion-count 1
// --parallelism 1
// --image "$CONTAINER_REGISTRY_NAME.azurecr.io/$CONTAINER_IMAGE_NAME"
// --cpu "2.0" --memory "4Gi"
// --secrets "personal-access-token=$AZP_TOKEN" "organization-url=$ORGANIZATION_URL"
// --env-vars "AZP_TOKEN=secretref:personal-access-token" "AZP_URL=secretref:organization-url"
// "AZP_POOL=$AZP_POOL" "AZP_PLACEHOLDER=1" "AZP_AGENT_NAME=placeholder-agent"
// --registry-server "$CONTAINER_REGISTRY_NAME.azurecr.io"
//
