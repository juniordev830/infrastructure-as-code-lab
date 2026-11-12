run "forecast_guardrail_is_advisory_by_default" {
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
      output.forecast_risk_summary.enforcement_enabled == false
    )
    error_message = "Default settings must report overages without blocking a plan."
  }
}

run "forecast_guardrail_allows_safe_growth" {
  command = plan

  variables {
    enforce_forecast_budget_limit = true
    estimated_monthly_cost_usd    = 60
    monthly_budget_usd            = 100
    monthly_growth_rate_percent   = 10
    forecast_months               = 3
  }

  assert {
    condition = (
      output.forecast_risk_summary.status == "within_budget" &&
      output.forecast_risk_summary.enforcement_enabled == true &&
      output.forecast_risk_summary.count_over_budget == 0
    )
    error_message = "Future estimates below budget must permit planning."
  }
}

run "forecast_guardrail_rejects_future_overage" {
  command = plan

  variables {
    enforce_forecast_budget_limit = true
    estimated_monthly_cost_usd    = 95
    monthly_budget_usd            = 100
    monthly_growth_rate_percent   = 10
    forecast_months               = 3
  }

  expect_failures = [terraform_data.environment]
}

run "forecast_guardrail_requires_positive_budget" {
  command = plan

  variables {
    enforce_forecast_budget_limit = true
    estimated_monthly_cost_usd    = 50
    monthly_budget_usd            = 0
  }

  expect_failures = [terraform_data.environment]
}

run "forecast_guardrail_accepts_exact_budget" {
  command = plan

  variables {
    enforce_forecast_budget_limit = true
    estimated_monthly_cost_usd    = 100
    monthly_budget_usd            = 100
    monthly_growth_rate_percent   = 0
    forecast_months               = 3
  }

  assert {
    condition = (
      output.forecast_risk_summary.status == "within_budget" &&
      output.forecast_risk_summary.first_breach_month == null
    )
    error_message = "An estimate exactly at the budget must be valid."
  }
}

run "forecast_guardrail_blocks_first_month_even_if_cost_falls" {
  command = plan

  variables {
    enforce_forecast_budget_limit = true
    estimated_monthly_cost_usd    = 150
    monthly_budget_usd            = 100
    monthly_growth_rate_percent   = -50
    forecast_months               = 3
  }

  expect_failures = [terraform_data.environment]
}

run "forecast_guardrail_can_be_independent_from_initial_guardrail" {
  command = plan

  variables {
    enforce_forecast_budget_limit = false
    enforce_budget_limit          = true
    estimated_monthly_cost_usd    = 95
    monthly_budget_usd            = 100
    monthly_growth_rate_percent   = 10
    forecast_months               = 3
  }

  assert {
    condition = (
      output.budget_summary.enforcement_enabled == true &&
      output.forecast_risk_summary.enforcement_enabled == false &&
      output.forecast_risk_summary.count_over_budget == 2
    )
    error_message = "Initial-month and forecast-wide guardrails must remain independent."
  }
}
