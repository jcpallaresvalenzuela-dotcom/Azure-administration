module "acr_task_delete_repos" {
  source   = "../modules/acr-task-delete-repos"
  for_each = var.acr_tasks

  resource_group_name = each.value.resource_group_name
  acr_name            = each.value.acr_name

  # Si no se provee, usa valores por defecto del módulo
  task_name     = lookup(each.value, "task_name", "delete-acr-repos-daily")
  schedule_cron = lookup(each.value, "schedule_cron", "0 1 * * *") # UTC
}
