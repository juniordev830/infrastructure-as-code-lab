# Independent cumulative cap for the manually estimated forecast horizon.
variable "forecast_total_budget_usd" {
  description = "Optional total budget in USD for the full projected period; zero disables the comparison."
  type        = number
  default     = 0

  validation {
    condition     = var.forecast_total_budget_usd >= 0 && var.forecast_total_budget_usd <= 240000000
    error_message = "forecast_total_budget_usd must be between 0 and 240000000 USD."
  }
}

variable "enforce_forecast_total_budget" {
  description = "When true, require a positive forecast_total_budget_usd and reject cumulative cost above it."
  type        = bool
  default     = false
}

locals {
  forecast_total_budget_status = var.forecast_total_budget_usd == 0 ? "not_configured" : (
    local.forecast_total_usd > var.forecast_total_budget_usd ? "over_budget" : "within_budget"
  )
}

output "forecast_total_budget_summary" {
  description = "Advisory comparison of manually projected cumulative costs against a period-wide cap."
  value = {
    status                 = local.forecast_total_budget_status
    total_budget_usd       = var.forecast_total_budget_usd
    total_projected_usd    = local.forecast_total_usd
    enforcement_enabled    = var.enforce_forecast_total_budget
    remaining_usd          = var.forecast_total_budget_usd == 0 ? null : var.forecast_total_budget_usd - local.forecast_total_usd
    utilization_percent    = var.forecast_total_budget_usd == 0 ? null : local.forecast_total_usd / var.forecast_total_budget_usd * 100
  }
}
