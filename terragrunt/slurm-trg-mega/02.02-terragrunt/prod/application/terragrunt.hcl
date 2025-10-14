include "account" {
  path = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "${find_in_parent_folders("02.00-modules")}/ig"
}

inputs = {
  ig_name = include.account.locals.environment
  vpc_id = dependency.vpc.outputs.network_id
  subnet_ids = [for s in dependency.vpc.outputs.subnets: s.id]
}

dependency "vpc" {
  config_path = "../network"
  mock_outputs ={
    network_id = "test"
    subnets = [{
      id = "test"
    }]
  }
}