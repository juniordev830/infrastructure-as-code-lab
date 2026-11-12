run "budget_not_configured" {
  command = plan

  assert {
    condition     = output.budget_summary.status == "not_configured" && output.budget_summary.remaining_usd == null && output.budget_summary.utilization_percent == null
    error_message = "Zero budget must disable comparisons."
  }
}

run "within_budget" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 80
    monthly_budget_usd         = 100
  }

  assert {
    condition     = output.budget_summary.status == "within_budget" && output.budget_summary.remaining_usd == 20
    error_message = "A cost below the limit should preserve the remaining budget."
  }

  assert {
    condition     = output.budget_summary.utilization_percent == 80
    error_message = "An 80 USD estimate against 100 USD budget should use 80 percent."
  }
}

run "exact_budget_boundary" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 100
    monthly_budget_usd         = 100
  }

  assert {
    condition = (
      output.budget_summary.status == "within_budget" &&
      output.budget_summary.remaining_usd == 0 &&
      output.budget_summary.utilization_percent == 100
    )
    error_message = "Spending exactly the budget is not over budget."
  }
}

run "over_budget" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 125
    monthly_budget_usd         = 100
  }

  assert {
    condition     = output.budget_summary.status == "over_budget" && output.budget_summary.remaining_usd == -25
    error_message = "Exceeding the limit must be visible."
  }
}

run "invalid_budget_is_rejected" {
  command = plan

  variables {
    monthly_budget_usd = -1
  }

  expect_failures = [var.monthly_budget_usd]
}

run "invalid_estimate_is_rejected" {
  command = plan

  variables {
    estimated_monthly_cost_usd = -0.01
  }

  expect_failures = [var.estimated_monthly_cost_usd]
}

run "over_budget_is_advisory_by_default" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 150
    monthly_budget_usd         = 100
  }

  assert {
    condition     = output.budget_summary.status == "over_budget" && output.budget_summary.enforcement_enabled == false
    error_message = "The default mode must preserve backwards-compatible advisory behavior."
  }
}

run "enforced_budget_allows_lower_estimate" {
  command = plan

  variables {
    enforce_budget_limit       = true
    estimated_monthly_cost_usd = 75
    monthly_budget_usd         = 100
  }

  assert {
    condition = (
      output.budget_summary.status == "within_budget" &&
      output.budget_summary.enforcement_enabled == true &&
      output.budget_summary.remaining_usd == 25
    )
    error_message = "An estimate below the configured limit must still be plannable."
  }
}

run "enforced_budget_allows_exact_limit" {
  command = plan

  variables {
    enforce_budget_limit       = true
    estimated_monthly_cost_usd = 100
    monthly_budget_usd         = 100
  }

  assert {
    condition     = output.budget_summary.status == "within_budget" && output.budget_summary.remaining_usd == 0
    error_message = "Equality with the budget must not block planning."
  }
}

run "enforced_budget_rejects_overage" {
  command = plan

  variables {
    enforce_budget_limit       = true
    estimated_monthly_cost_usd = 101
    monthly_budget_usd         = 100
  }

  expect_failures = [terraform_data.environment]
}

run "enforcement_requires_positive_budget" {
  command = plan

  variables {
    enforce_budget_limit = true
  }

  expect_failures = [terraform_data.environment]
}
