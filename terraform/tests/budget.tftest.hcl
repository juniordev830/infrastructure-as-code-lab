run "budget_not_configured" {
  command = plan

  assert {
    condition     = output.budget_summary.status == "not_configured" && output.budget_summary.remaining_usd == null
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
