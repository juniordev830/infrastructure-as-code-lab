output "environment_summary" {
  description = "Validated metadata (no infrastructure provisioned)"
  value       = terraform_data.environment.output
}
