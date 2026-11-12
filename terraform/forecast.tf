# Offline forecast from manually supplied monthly estimates. No provider calls.
variable "forecast_months" {
  description = "Number of months to project, including the starting month (1 to 24)."
  type        = number
  default     = 3

  validation {
    condition     = var.forecast_months >= 1 && var.forecast_months <= 24 && floor(var.forecast_months) == var.forecast_months
    error_message = "forecast_months must be an integer between 1 and 24."
  }
}

variable "monthly_growth_rate_percent" {
  description = "Compounded month-over-month change in the manual estimate (-100 to 100 percent)."
  type        = number
  default     = 0

  validation {
    condition     = var.monthly_growth_rate_percent >= -100 && var.monthly_growth_rate_percent <= 100
    error_message = "monthly_growth_rate_percent must be between -100 and 100."
  }
}

locals {
  monthly_projection = [
    for month in range(1, var.forecast_months + 1) : {
      month              = month
      projected_cost_usd = round(var.estimated_monthly_cost_usd * pow(1 + var.monthly_growth_rate_percent / 100, month - 1) * 100) / 100
    }
  ]
}

output "forecast_summary" {
  description = "Advisory monthly cost projection based on user-provided assumptions, not real invoices."
  value = {
    forecast_months     = var.forecast_months
    growth_rate_percent = var.monthly_growth_rate_percent
    monthly_projection = [
      for month in local.monthly_projection : {
        month              = month.month
        projected_cost_usd = month.projected_cost_usd
        exceeds_budget     = var.monthly_budget_usd == 0 ? null : month.projected_cost_usd > var.monthly_budget_usd
      }
    ]
  }
}
