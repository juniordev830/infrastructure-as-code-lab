# Offline early-warning indicators for manually entered monthly cost projections.
variable "budget_warning_threshold_percent" {
  description = "Budget utilization percentage at which to warn (0-100, default 80); overages remain separate."
  type        = number
  default     = 80

  validation {
    condition     = var.budget_warning_threshold_percent >= 0 && var.budget_warning_threshold_percent <= 100
    error_message = "budget_warning_threshold_percent must be between 0 and 100."
  }
}

locals {
  forecast_warning_months = var.monthly_budget_usd == 0 ? [] : [
    for month in local.monthly_projection : month.month
    if(
      month.projected_cost_usd >= var.monthly_budget_usd * var.budget_warning_threshold_percent / 100 &&
      month.projected_cost_usd <= var.monthly_budget_usd
    )
  ]

  forecast_warning_status = var.monthly_budget_usd == 0 ? "not_configured" : (
    length(local.forecast_budget_breaches) > 0 ? "over_budget" : (
      length(local.forecast_warning_months) > 0 ? "warning" : "healthy"
    )
  )
}

output "forecast_warning_summary" {
  description = "Advisory alert when a manually projected monthly cost approaches the configured budget."
  value = {
    status                    = local.forecast_warning_status
    warning_threshold_percent = var.budget_warning_threshold_percent
    warning_months            = local.forecast_warning_months
    warning_month_count       = length(local.forecast_warning_months)
    first_warning_month       = length(local.forecast_warning_months) == 0 ? null : local.forecast_warning_months[0]
    over_budget_months        = local.forecast_budget_breaches
  }
}
