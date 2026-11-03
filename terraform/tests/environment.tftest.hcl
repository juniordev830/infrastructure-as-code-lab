run "planned_metadata" {
  command = plan

  variables {
    environment  = "staging"
    owner        = "platform"
    service_name = "inventory-api"
  }

  assert {
    condition = (
      terraform_data.environment.input.environment == "staging" &&
      terraform_data.environment.input.owner == "platform" &&
      terraform_data.environment.input.service == "inventory-api"
    )
    error_message = "The plan must preserve the environment, owner and service name."
  }
}

run "reject_unknown_environment" {
  command = plan

  variables {
    environment = "sandbox"
  }

  expect_failures = [var.environment]
}
