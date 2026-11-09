# Offline budgeting example: these numbers are user-entered estimates.
# This file does not connect to a provider or provision cloud resources.
variable "estimated_monthly_cost_usd" {
  description = "Estimated monthly cloud cost in USD, entered manually."
  type        = number
  default     = 0

  validation {
    condition     = var.estimated_monthly_cost_usd >= 0 && var.estimated_monthly_cost_usd <= 10000000
    error_message = "Estimated monthly cost must be between 0 and 10000000 USD."
  }
}

variable "monthly_budget_usd" {
  description = "Optional monthly budget in USD; zero disables budget comparisons."
  type        = number
  default     = 0

  validation {
    condition     = var.monthly_budget_usd >= 0 && var.monthly_budget_usd <= 10000000
    error_message = "Monthly budget must be between 0 and 10000000 USD."
  }
}

locals {
  budget_status = var.monthly_budget_usd == 0 ? "not_configured" : (
    var.estimated_monthly_cost_usd > var.monthly_budget_usd ? "over_budget" : "within_budget"
  )
}

output "budget_summary" {
  description = "Advisory comparison of manually entered estimates; not actual billing data."
  value = {
    estimated_monthly_cost_usd = var.estimated_monthly_cost_usd
    monthly_budget_usd         = var.monthly_budget_usd
    status                     = local.budget_status
    remaining_usd              = var.monthly_budget_usd == 0 ? null : var.monthly_budget_usd - var.estimated_monthly_cost_usd
  }
}
