run "allocation_defaults_to_unconfigured" {
  command = plan

  assert {
    condition = (
      output.allocation_summary.status == "not_configured" &&
      output.allocation_summary.service_count == 0 &&
      output.allocation_summary.enforcement_enabled == false
    )
    error_message = "An empty map must preserve the default advisory behavior."
  }
}

run "allocated_services_reconcile" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 100
    service_costs_usd = {
      api      = 60
      database = 40
    }
  }

  assert {
    condition = (
      output.allocation_summary.status == "matched" &&
      output.allocation_summary.service_count == 2 &&
      output.allocation_summary.allocated_total_usd == 100 &&
      output.allocation_summary.services.api.share_percent == 60 &&
      output.allocation_summary.services.database.share_percent == 40
    )
    error_message = "Complete cost allocations must reconcile and calculate service shares."
  }
}

run "underallocated_services_are_reported" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 150
    service_costs_usd = {
      api      = 60
      database = 40
    }
  }

  assert {
    condition = (
      output.allocation_summary.status == "underallocated" &&
      output.allocation_summary.difference_usd == -50
    )
    error_message = "A lower allocated total must be reported without blocking the plan by default."
  }
}

run "overallocated_services_are_reported" {
  command = plan

  variables {
    estimated_monthly_cost_usd = 100
    service_costs_usd = {
      api      = 60
      database = 60
    }
  }

  assert {
    condition = (
      output.allocation_summary.status == "overallocated" &&
      output.allocation_summary.difference_usd == 20
    )
    error_message = "A higher allocated total must be distinguished from missing allocations."
  }
}

run "zero_allocated_total_has_no_service_percentage" {
  command = plan

  variables {
    service_costs_usd = {
      api = 0
    }
  }

  assert {
    condition = (
      output.allocation_summary.status == "matched" &&
      output.allocation_summary.services.api.share_percent == null
    )
    error_message = "Service shares must avoid division by zero."
  }
}

run "enforced_matching_allows_reconciled_services" {
  command = plan

  variables {
    enforce_allocation_match   = true
    estimated_monthly_cost_usd = 100
    service_costs_usd = {
      api = 100
    }
  }

  assert {
    condition = (
      output.allocation_summary.status == "matched" &&
      output.allocation_summary.enforcement_enabled == true
    )
    error_message = "An exact match must be plannable when enforcement is enabled."
  }
}

run "enforced_matching_rejects_unallocated_costs" {
  command = plan

  variables {
    enforce_allocation_match   = true
    estimated_monthly_cost_usd = 100
    service_costs_usd = {
      api = 90
    }
  }

  expect_failures = [terraform_data.environment]
}

run "enforced_matching_requires_services" {
  command = plan

  variables {
    enforce_allocation_match = true
  }

  expect_failures = [terraform_data.environment]
}

run "invalid_service_identifier_is_rejected" {
  command = plan

  variables {
    service_costs_usd = {
      "Bad Service" = 1
    }
  }

  expect_failures = [var.service_costs_usd]
}

run "negative_service_cost_is_rejected" {
  command = plan

  variables {
    service_costs_usd = {
      api = -1
    }
  }

  expect_failures = [var.service_costs_usd]
}

run "too_many_services_are_rejected" {
  command = plan

  variables {
    service_costs_usd = {
      for index in range(26) : format("service-%02d", index) => 1
    }
  }

  expect_failures = [var.service_costs_usd]
}
