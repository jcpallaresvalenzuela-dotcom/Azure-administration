variable "acr_tasks" {
  description = "Listado de ACRs a los que crear la Task de borrado. Clave libre (id), valor con datos del ACR."
  type = map(object({
    resource_group_name = string
    acr_name            = string
    schedule_cron       = optional(string, "0 1 * * *")
    task_name           = optional(string, "delete-acr-repos-daily")
  }))
  sensitive = true
}
