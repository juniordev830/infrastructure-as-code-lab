terraform {
  required_version = ">= 1.5.0"
}

# Provider-free, cost-free Terraform exercise; NO cloud resources are provisioned.
resource "terraform_data" "environment" {
  input = {
    environment = var.environment
    owner       = var.owner
    service     = var.service_name
  }
}
