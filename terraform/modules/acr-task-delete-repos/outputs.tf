output "task_id" {
  value = azurerm_container_registry_task.delete_repos.id
}

output "task_name" {
  value = azurerm_container_registry_task.delete_repos.name
}

output "schedule" {
  value = var.schedule_cron
}