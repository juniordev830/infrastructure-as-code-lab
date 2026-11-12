run "warning_not_configured_without_budget" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 90
    forecast_months            = 3
  }

  assert {
    condition = (
      output.forecast_warning_summary.status == "not_configured" &&
      output.forecast_warning_summary.warning_month_count == 0 &&
      output.forecast_warning_summary.first_warning_month == null
    )
    error_message = "Without a budget, no utilization warning is meaningful."
  }
}

run "healthy_when_all_months_below_threshold" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 79
    monthly_budget_usd         = 100
    forecast_months            = 3
  }

  assert {
    condition = (
      output.forecast_warning_summary.status == "healthy" &&
      output.forecast_warning_summary.warning_month_count == 0
    )
    error_message = "Costs below the warning threshold should be healthy."
  }
}

run "warning_begins_at_exact_threshold" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 80
    monthly_budget_usd         = 100
    forecast_months            = 2
  }

  assert {
    condition = (
      output.forecast_warning_summary.status == "warning" &&
      output.forecast_warning_summary.warning_threshold_percent == 80 &&
      output.forecast_warning_summary.warning_months == [1, 2] &&
      output.forecast_warning_summary.first_warning_month == 1
    )
    error_message = "The threshold is inclusive and should detect both months."
  }
}

run "warning_at_budget_limit_is_not_overage" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 100
    monthly_budget_usd         = 100
    forecast_months            = 1
  }

  assert {
    condition = (
      output.forecast_warning_summary.status == "warning" &&
      output.forecast_warning_summary.warning_months == [1] &&
      length(output.forecast_warning_summary.over_budget_months) == 0
    )
    error_message = "Exact budget equality must be a warning rather than an overage."
  }
}

run "over_budget_takes_precedence_over_warning" {
  command = plan

  variables {
    estimated_monthly_cost_usd  = 95
    monthly_budget_usd          = 100
    monthly_growth_rate_percent = 10
    forecast_months             = 3
  }

  assert {
    condition = (
      output.forecast_warning_summary.status == "over_budget" &&
      output.forecast_warning_summary.warning_months == [1] &&
      output.forecast_warning_summary.over_budget_months == [2, 3]
    )
    error_message = "Forecast risk must prioritize breached months while preserving earlier warnings."
  }
}

run "custom_warning_threshold" {
  command = plan

  variables {
    budget_warning_threshold_percent = 90
    estimated_monthly_cost_usd       = 85
    monthly_budget_usd               = 100
    forecast_months                  = 2
  }

  assert {
    condition = (
      output.forecast_warning_summary.status == "healthy" &&
      output.forecast_warning_summary.warning_threshold_percent == 90
    )
    error_message = "User-configured thresholds must override the 80-percent default."
  }
}

run "reject_negative_warning_threshold" {
  command = plan

  variables {
    budget_warning_threshold_percent = -1
  }

  expect_failures = [var.budget_warning_threshold_percent]
}

run "reject_warning_threshold_above_100" {
  command = plan

  variables {
    budget_warning_threshold_percent = 101
  }

  expect_failures = [var.budget_warning_threshold_percent]
}
