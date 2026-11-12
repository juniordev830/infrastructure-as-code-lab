run "cumulative_budget_unconfigured_by_default" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 100
    forecast_months            = 3
  }

  assert {
    condition = (
      output.forecast_total_budget_summary.status == "not_configured" &&
      output.forecast_total_budget_summary.total_projected_usd == 300 &&
      output.forecast_total_budget_summary.remaining_usd == null &&
      output.forecast_total_budget_summary.utilization_percent == null &&
      output.forecast_total_budget_summary.enforcement_enabled == false
    )
    error_message = "An unset period-wide budget must remain advisory and safe for zero divisors."
  }
}

run "cumulative_budget_below_cap" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 80
    forecast_months            = 3
    forecast_total_budget_usd   = 300
  }

  assert {
    condition = (
      output.forecast_total_budget_summary.status == "within_budget" &&
      output.forecast_total_budget_summary.total_projected_usd == 240 &&
      output.forecast_total_budget_summary.remaining_usd == 60 &&
      output.forecast_total_budget_summary.utilization_percent == 80
    )
    error_message = "The full period must reconcile the cumulative total and percentage used."
  }
}

run "cumulative_budget_exact_boundary" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 100
    forecast_months            = 3
    forecast_total_budget_usd   = 300
  }

  assert {
    condition = (
      output.forecast_total_budget_summary.status == "within_budget" &&
      output.forecast_total_budget_summary.remaining_usd == 0 &&
      output.forecast_total_budget_summary.utilization_percent == 100
    )
    error_message = "Equality with the cumulative cap must not be flagged as over budget."
  }
}

run "cumulative_budget_overage_is_advisory" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 100
    forecast_months            = 3
    forecast_total_budget_usd   = 250
  }

  assert {
    condition = (
      output.forecast_total_budget_summary.status == "over_budget" &&
      output.forecast_total_budget_summary.remaining_usd == -50 &&
      output.forecast_total_budget_summary.enforcement_enabled == false
    )
    error_message = "Default mode must report overages without rejecting the plan."
  }
}

run "cumulative_budget_enforcement_allows_safe_total" {
  command = plan

  variables {
    estimated_monthly_cost_usd     = 80
    forecast_months                = 3
    forecast_total_budget_usd      = 240
    enforce_forecast_total_budget  = true
  }

  assert {
    condition = (
      output.forecast_total_budget_summary.status == "within_budget" &&
      output.forecast_total_budget_summary.enforcement_enabled == true &&
      output.forecast_total_budget_summary.remaining_usd == 0
    )
    error_message = "Cumulative enforcement must allow a total exactly at its cap."
  }
}

run "cumulative_enforcement_independent_from_monthly_cap" {
  command = plan

  variables {
    estimated_monthly_cost_usd     = 80
    monthly_budget_usd             = 100
    forecast_months                = 3
    enforce_forecast_budget_limit  = true
    forecast_total_budget_usd      = 200
    enforce_forecast_total_budget  = true
  }

  expect_failures = [terraform_data.environment]
}

run "cumulative_enforcement_requires_positive_budget" {
  command = plan

  variables {
    enforce_forecast_total_budget = true
  }

  expect_failures = [terraform_data.environment]
}

run "reject_negative_cumulative_budget" {
  command = plan

  variables {
    forecast_total_budget_usd = -1
  }

  expect_failures = [var.forecast_total_budget_usd]
}

run "reject_cumulative_budget_above_cap" {
  command = plan

  variables {
    forecast_total_budget_usd = 240000001
  }

  expect_failures = [var.forecast_total_budget_usd]
}
