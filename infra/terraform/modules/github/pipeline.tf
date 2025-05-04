// oidc_template.tf

resource "github_actions_repository_oidc_subject_claim_customization_template" "this" {
  repository  = github_repository.this.name
  use_default = false
  include_claim_keys = [
    "repository",
    "environment",
    "job_workflow_ref"
  ]

  depends_on = [
    github_repository.this,
  ]
}

locals {
  template_claim_structure = "${var.organization_name}/${var.templates_repository_name}/%s@${local.default_branch}"

  oidc_subjects_flattened = flatten(
    [
      for key, value in var.workflows
      : [
        for environment_user_assigned_managed_identity_mapping in value.environment_user_assigned_managed_identity_mappings
        : {
          subject_key                        = "${key}-${environment_user_assigned_managed_identity_mapping.user_assigned_managed_identity_key}"
          user_assigned_managed_identity_key = environment_user_assigned_managed_identity_mapping.user_assigned_managed_identity_key
          subject                            = "repo:${var.organization_name}/${var.main_repository_name}:environment:${var.environments[environment_user_assigned_managed_identity_mapping.environment_key].name}:job_workflow_ref:${format(local.template_claim_structure, value.workflow_file_name)}"
        }
      ]
    ]
  )

  oidc_subjects = { for oidc_subject in local.oidc_subjects_flattened : oidc_subject.subject_key => {
    user_assigned_managed_identity_key = oidc_subject.user_assigned_managed_identity_key
    subject                            = oidc_subject.subject
  } }
}
