run "flat_forecast_preserves_baseline" {
  command = plan

  variables {
    forecast_months            = 3
    monthly_growth_rate_percent = 0
    estimated_monthly_cost_usd = 80
    monthly_budget_usd         = 100
  }

  assert {
    condition = (
      length(output.forecast_summary.monthly_projection) == 3 &&
      output.forecast_summary.monthly_projection[0].month == 1 &&
      output.forecast_summary.monthly_projection[0].projected_cost_usd == 80 &&
      output.forecast_summary.monthly_projection[2].projected_cost_usd == 80 &&
      output.forecast_summary.monthly_projection[2].exceeds_budget == false
    )
    error_message = "Zero growth must keep the manual estimate constant across months."
  }
}

run "compounding_growth_flags_future_overage" {
  command = plan

  variables {
    forecast_months            = 3
    monthly_growth_rate_percent = 10
    estimated_monthly_cost_usd = 95
    monthly_budget_usd         = 100
  }

  assert {
    condition = (
      output.forecast_summary.monthly_projection[0].projected_cost_usd == 95 &&
      output.forecast_summary.monthly_projection[1].projected_cost_usd == 104.5 &&
      output.forecast_summary.monthly_projection[2].projected_cost_usd == 114.95 &&
      output.forecast_summary.monthly_projection[0].exceeds_budget == false &&
      output.forecast_summary.monthly_projection[1].exceeds_budget == true
    )
    error_message = "Compounded cost growth must expose future estimated budget breaches."
  }
}

run "negative_growth_reduces_forecast" {
  command = plan

  variables {
    forecast_months            = 3
    monthly_growth_rate_percent = -10
    estimated_monthly_cost_usd = 100
  }

  assert {
    condition = (
      output.forecast_summary.monthly_projection[1].projected_cost_usd == 90 &&
      output.forecast_summary.monthly_projection[2].projected_cost_usd == 81 &&
      output.forecast_summary.monthly_projection[1].exceeds_budget == null
    )
    error_message = "Negative growth must reduce forecasts and unset comparisons without a budget."
  }
}

run "invalid_zero_forecast_months" {
  command = plan

  variables {
    forecast_months = 0
  }

  expect_failures = [var.forecast_months]
}

run "reject_fractional_forecast_months" {
  command = plan

  variables {
    forecast_months = 1.5
  }

  expect_failures = [var.forecast_months]
}

run "reject_out_of_range_growth" {
  command = plan

  variables {
    monthly_growth_rate_percent = 101
  }

  expect_failures = [var.monthly_growth_rate_percent]
}
