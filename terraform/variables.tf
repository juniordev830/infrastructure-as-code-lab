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
}
variable "service_name" {
  type        = string
  description = "Sample service name"
  default     = "demo-api"
}
