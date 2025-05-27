// _variables.job.event.tf

variable "event_jobs" {
  type = set(
    object({
      event_job_name                 = string
      replica_timeout                = optional(number, 1800)
      replica_retry_limit            = optional(number, 0)
      event_parallelism              = optional(number, 1)
      event_replica_completion_count = optional(number, 1)
      workload_profile_name          = optional(string, null)
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
      event_scale = optional(object({
        max_executions   = optional(number, 100)
        min_executions   = optional(number, 0)
        polling_interval = optional(number, 30)
        rules = optional(set(
          object({
            name             = string
            custom_rule_type = string
            metadata         = any
            authentication = optional(set(object({
              secret_name       = optional(string, null)
              trigger_parameter = optional(string, null)
            })), [])
          })
        ), [])
      }))
    })
  )
  description = "List of manual jobs to be created"
  sensitive   = true
  default     = []
}

//
// Sample Job Configuration with Azure CLI (for reference only):
// --trigger-type Event
// --replica-timeout 1800
// --replica-retry-limit 0
// --replica-completion-count 1
// --parallelism 1
// --image "$CONTAINER_REGISTRY_NAME.azurecr.io/$CONTAINER_IMAGE_NAME"
// --min-executions 0
// --max-executions 10
// --polling-interval 30
// --scale-rule-name "azure-pipelines"
// --scale-rule-type "azure-pipelines"
// --scale-rule-metadata "poolName=$AZP_POOL" "targetPipelinesQueueLength=1"
// --scale-rule-auth "personalAccessToken=personal-access-token" "organizationURL=organization-url"
// --cpu "2.0" --memory "4Gi"
// --secrets "personal-access-token=$AZP_TOKEN" "organization-url=$ORGANIZATION_URL"
// --env-vars "AZP_TOKEN=secretref:personal-access-token" "AZP_URL=secretref:organization-url" "AZP_POOL=$AZP_POOL"
// --registry-server "$CONTAINER_REGISTRY_NAME.azurecr.io"
//
