module "acr_task_delete_repos" {
  source              = "../modules/acr-task-delete-repos"
  resource_group_name = var.resource_group_name
  acr_name            = var.acr_name
  schedule_cron       = "0 1 * * *"  # 01:00 UTC (~03:00 Madrid en verano)
}
