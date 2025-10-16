module "networking" {
  source = "github.com/pauljamm/yc-terraform-modules//networking"

  network_name = "test"
}

module "ig" {
  source = "./modules/ig"

  ig_name = "demo"
  vpc_id = module.networking.vpc_id
  subnet_ids = [for s in module.networking.subnets : s.id]
}

module "lb" {
  source = "./modules/lb"

  lb_name = "demo"
  vpc_id = module.networking.vpc_id
  target_group_ids = [module.ig.target_group_id]
  subnets = [for s in module.networking.subnets : {
    "id" = s.id
    "zone" = s.zone
  }]
}
