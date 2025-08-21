locals {
  # Contenido YAML de la task (base64)
  acr_task_yaml_b64 = base64encode(templatefile("${path.module}/acr-task.yaml.tftpl", {
    login_server   = data.azurerm_container_registry.acr.login_server
    admin_username = try(data.azurerm_container_registry.acr.admin_username, null)
    admin_password = try(data.azurerm_container_registry.acr.admin_password, null)
  }))
}

resource "azurerm_container_registry_task" "delete_repos" {
  name                 = var.task_name
  container_registry_id = data.azurerm_container_registry.acr.id
  platform { os = "Linux" } # Task runner OS

  encoded_step {
    task_content = local.acr_task_yaml_b64
  }

  timer_trigger {
    name     = "daily"
    schedule = var.schedule_cron # UTC
    enabled  = true
  }

  # (Opcional) tags
  tags = {
    purpose = "acr-repos-delete-daily"
  }
}
