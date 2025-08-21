variable "resource_group_name" {
  type      = string
  sensitive = true
}

variable "acr_name" {
  type      = string
  sensitive = true
}

variable "schedule_cron" {
  type        = string
  default     = "0 1 * * *"
}


