run "risk_summary_without_budget" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 20
    forecast_months            = 3
  }

  assert {
    condition = (
      output.forecast_risk_summary.status == "not_configured" &&
      output.forecast_risk_summary.total_projected_usd == 60 &&
      output.forecast_risk_summary.peak_monthly_usd == 20 &&
      output.forecast_risk_summary.count_over_budget == 0 &&
      output.forecast_risk_summary.first_breach_month == null
    )
    error_message = "Without a budget, risk indicators must remain unconfigured."
  }
}

run "risk_summary_detects_first_future_breach" {
  command = plan

  variables {
    estimated_monthly_cost_usd  = 95
    monthly_budget_usd          = 100
    monthly_growth_rate_percent = 10
    forecast_months             = 3
  }

  assert {
    condition = (
      output.forecast_risk_summary.status == "over_budget" &&
      output.forecast_risk_summary.first_breach_month == 2 &&
      output.forecast_risk_summary.count_over_budget == 2 &&
      output.forecast_risk_summary.peak_monthly_usd == 114.95 &&
      output.forecast_risk_summary.total_projected_usd == 314.45
    )
    error_message = "Risk metrics must aggregate the same values shown in the monthly forecast."
  }
}

run "risk_summary_respects_exact_limit" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 100
    monthly_budget_usd         = 100
    forecast_months            = 2
  }

  assert {
    condition = (
      output.forecast_risk_summary.status == "within_budget" &&
      output.forecast_risk_summary.count_over_budget == 0 &&
      output.forecast_risk_summary.first_breach_month == null
    )
    error_message = "A value equal to the budget must not be flagged as a breach."
  }
}

run "risk_summary_can_start_above_budget" {
  command = plan

  variables {
    estimated_monthly_cost_usd  = 150
    monthly_budget_usd          = 100
    monthly_growth_rate_percent = -50
    forecast_months             = 3
  }

  assert {
    condition = (
      output.forecast_risk_summary.status == "over_budget" &&
      output.forecast_risk_summary.first_breach_month == 1 &&
      output.forecast_risk_summary.count_over_budget == 1 &&
      output.forecast_risk_summary.peak_monthly_usd == 150
    )
    error_message = "Declining forecasts still need to report a breach in the first month."
  }
}

run "risk_summary_single_month" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 25
    forecast_months            = 1
    monthly_budget_usd         = 30
  }

  assert {
    condition = (
      output.forecast_risk_summary.total_projected_usd == 25 &&
      output.forecast_risk_summary.peak_monthly_usd == 25 &&
      output.forecast_risk_summary.count_over_budget == 0
    )
    error_message = "A single-month projection must have consistent cumulative metrics."
  }
}
