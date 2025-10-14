locals {
  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets = data.terraform_remote_state.vpc.outputs.subnets
}

module "ig" {
  source = "../../../02.00-modules/ig"

  ig_name    = var.name
  image_id   = var.image_id
  vpc_id     = local.vpc_id
  subnet_ids = [for s in local.subnets : s.id]
}

module "lb" {
  source = "../../../02.00-modules/lb"

  lb_name = var.name

  vpc_id = local.vpc_id
  subnets = [for s in local.subnets : {
    "id"   = s.id,
    "zone" = s.zone
  }]
  target_group_ids = [module.ig.target_group_id]
}
