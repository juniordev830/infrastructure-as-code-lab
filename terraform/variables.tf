variable "environment" {
  type        = string
  description = "Environment name"
  default     = "development"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Use development, staging or production"
  }
}
variable "owner" {
  type        = string
  description = "Technical team identifier"
  default     = "engineering"

  validation {
    condition     = length(trimspace(var.owner)) >= 2 && length(trimspace(var.owner)) <= 64
    error_message = "owner must contain between 2 and 64 non-space characters."
  }
}
variable "service_name" {
  type        = string
  description = "Sample service name"
  default     = "demo-api"

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?$", var.service_name))
    error_message = "service_name must use lowercase letters, numbers and hyphens."
  }
}
