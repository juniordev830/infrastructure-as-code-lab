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

    precondition {
      condition = (
        !var.enforce_allocation_match ||
        (length(var.service_costs_usd) > 0 && local.allocation_matches)
      )
      error_message = "Allocation enforcement requires at least one service and a total matching estimated_monthly_cost_usd."
    }

    precondition {
      condition = (
        !var.enforce_forecast_budget_limit ||
        (var.monthly_budget_usd > 0 && length(local.forecast_budget_breaches) == 0)
      )
      error_message = "Forecast enforcement requires a positive monthly_budget_usd and no projected month above the monthly budget."
    }

    precondition {
      condition = (
        !var.enforce_forecast_total_budget ||
        (var.forecast_total_budget_usd > 0 && local.forecast_total_usd <= var.forecast_total_budget_usd)
      )
      error_message = "Cumulative forecast enforcement requires a positive forecast_total_budget_usd and no total projected cost above it."
    }
  }
}
