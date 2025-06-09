// _locals.tf

locals {
  github_actions_root  = ".github"
  workflow_directory   = "workflows"
  actions_directory    = "actions"
  ci_template_filename = "${local.workflow_directory}/ci-template.yaml"
  cd_template_filename = "${local.workflow_directory}/cd-template.yaml"

  main_files_path       = "${path.module}/files/main"
  template_files_path   = "${path.module}/files/templates"
  main_files            = fileset(local.main_files_path, "**/*.yaml")
  template_files        = fileset(local.template_files_path, "**/*.yaml")
  template_script_files = fileset(local.template_files_path, "**/scripts/*")
}

locals {
  runner_runs_on = var.runner_group_name != "" ? "group: ${var.runner_group_name}" : "ubuntu-latest"
}

locals {
  workflow_main_files = {
    for file in local.main_files
    : "${local.github_actions_root}/${file}" =>
    {
      content = templatefile("${local.main_files_path}/${file}", {
        owner_name                = var.organization_name
        project_name              = var.project_name
        templates_repository_name = var.use_templates_repository ? var.templates_repository_name : var.repository_name
        workflow_path             = "${local.github_actions_root}/${local.workflow_directory}"
        ci_template_path          = "${local.github_actions_root}/${local.ci_template_filename}"
        cd_template_path          = "${local.github_actions_root}/${local.cd_template_filename}"
        template_ref              = var.templates_ref
      })
    }
  }
}

locals {
  workflow_template_yaml_files = {
    for file in local.template_files
    : "${local.github_actions_root}/${file}" =>
    {
      content = templatefile("${local.template_files_path}/${file}", {
        owner_name                = var.organization_name
        project_name              = var.project_name
        templates_repository_name = var.use_templates_repository ? var.templates_repository_name : var.repository_name
        action_path               = "${local.github_actions_root}/${local.actions_directory}"
        template_ref              = var.templates_ref
        runner_runs_on            = local.runner_runs_on
      })
    }
  }
  workflow_template_script_files = {
    for file in local.template_script_files
    : "${local.github_actions_root}/${file}" =>
    {
      content = templatefile("${local.template_files_path}/${file}", {})
    }
  }
  workflow_template_files = merge(local.workflow_template_yaml_files, local.workflow_template_script_files)
}
