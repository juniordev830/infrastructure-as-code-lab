variable "enforce_forecast_budget_limit" {
  description = "When enabled, reject a plan if any month in the offline cost forecast exceeds a positive monthly budget."
  type        = bool
  default     = false
}

# Summarize risks across the offline, manually estimated monthly projection.
locals {
  forecast_budget_breaches = var.monthly_budget_usd == 0 ? [] : [
    for month in local.monthly_projection : month.month
    if month.projected_cost_usd > var.monthly_budget_usd
  ]

  forecast_total_usd = length(local.monthly_projection) == 0 ? 0 : sum([
    for month in local.monthly_projection : month.projected_cost_usd
  ])

  forecast_peak_usd = length(local.monthly_projection) == 0 ? 0 : max([
    for month in local.monthly_projection : month.projected_cost_usd
  ]...)

  forecast_risk_status = var.monthly_budget_usd == 0 ? "not_configured" : (
    length(local.forecast_budget_breaches) == 0 ? "within_budget" : "over_budget"
  )
}

output "forecast_risk_summary" {
  description = "Aggregate indicators derived from an illustrative forecast, not from real cloud invoices."
  value = {
    status              = local.forecast_risk_status
    total_projected_usd = local.forecast_total_usd
    peak_monthly_usd    = local.forecast_peak_usd
    months_over_budget  = local.forecast_budget_breaches
    count_over_budget   = length(local.forecast_budget_breaches)
    first_breach_month  = length(local.forecast_budget_breaches) == 0 ? null : local.forecast_budget_breaches[0]
  }
}
