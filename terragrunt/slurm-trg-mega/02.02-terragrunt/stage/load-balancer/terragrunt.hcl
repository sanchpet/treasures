include "account" {
  path = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "${find_in_parent_folders("02.00-modules")}/lb"
}

inputs = {
  lb_name = include.account.locals.environment
  vpc_id = dependency.vpc.outputs.network_id
  subnets = [for s in dependency.vpc.outputs.subnets: {
    "id" = s.id
    "zone" = s.zone
  }]
  target_group_ids = [dependency.application.outputs.target_group_id]
}

dependency "vpc" {
  config_path = "../network"
  mock_outputs ={
    network_id = "test"
    subnets = [{
      id = "test"
      zone = "test"
    }]
  }
}

dependency "application" {
  config_path = "../application"
  mock_outputs ={
    target_group_id = "test"
  }
}