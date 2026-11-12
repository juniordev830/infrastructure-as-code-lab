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

  lifecycle {
    precondition {
      condition = (
        !var.enforce_budget_limit ||
        (var.monthly_budget_usd > 0 && var.estimated_monthly_cost_usd <= var.monthly_budget_usd)
      )
      error_message = "Budget enforcement requires a positive monthly_budget_usd and an estimated_monthly_cost_usd not exceeding it."
    }
  }
}
