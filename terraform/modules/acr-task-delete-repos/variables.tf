variable "resource_group_name" {
  type        = string
  sensitive   = true
}

variable "acr_name" {
  type        = string
  sensitive   = true
}

variable "task_name" {
  type        = string
  default     = "delete-acr-repos-daily"
}

# Cron en UTC. Ej: "0 1 * * *" => 01:00 UTC cada día

variable "schedule_cron" {
  type        = string
  default     = "0 1 * * *"
}