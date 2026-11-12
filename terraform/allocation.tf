# Manual cost allocation by service. No billing API or cloud resources.
variable "service_costs_usd" {
  description = "Optional map of service identifiers to manually entered monthly costs in USD (up to 25 services)."
  type        = map(number)
  default     = {}

  validation {
    condition = (
      length(var.service_costs_usd) <= 25 &&
      alltrue([
        for name, cost in var.service_costs_usd :
        can(regex("^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?$", name)) &&
        cost >= 0 &&
        cost <= 10000000
      ])
    )
    error_message = "Use up to 25 lowercase service names (letters, numbers, hyphens), each with a cost from 0 to 10000000 USD."
  }
}

variable "enforce_allocation_match" {
  description = "When true, require a nonempty service_costs_usd map whose total matches estimated_monthly_cost_usd to the cent."
  type        = bool
  default     = false
}

locals {
  allocated_total_usd = length(var.service_costs_usd) == 0 ? 0 : sum(values(var.service_costs_usd))
  allocated_delta_usd = local.allocated_total_usd - var.estimated_monthly_cost_usd
  allocation_matches  = abs(local.allocated_delta_usd) < 0.005

  allocation_status = length(var.service_costs_usd) == 0 ? "not_configured" : (
    local.allocation_matches ? "matched" : (
      local.allocated_delta_usd < 0 ? "underallocated" : "overallocated"
    )
  )
}

output "allocation_summary" {
  description = "Offline allocation of manually entered estimates by service, with reconciliation against the total."
  value = {
    status              = local.allocation_status
    enforcement_enabled = var.enforce_allocation_match
    service_count       = length(var.service_costs_usd)
    allocated_total_usd = local.allocated_total_usd
    estimated_total_usd = var.estimated_monthly_cost_usd
    difference_usd      = local.allocated_delta_usd
    reconciled          = length(var.service_costs_usd) > 0 && local.allocation_matches
    services = {
      for name, cost in var.service_costs_usd : name => {
        monthly_cost_usd = cost
        share_percent    = local.allocated_total_usd == 0 ? null : floor(cost / local.allocated_total_usd * 10000 + 0.5) / 100
      }
    }
  }
}
