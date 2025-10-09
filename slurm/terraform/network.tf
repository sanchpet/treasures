locals {
  vpc_network_name    = var.vpc_network_name != null ? var.vpc_network_name : "${var.name_prefix}-private"
}

module "net" {
  source = "github.com/terraform-yc-modules/terraform-yc-vpc.git?ref=83627283982d5ad8268ab85f0e9842dc3da9f3d1" # Commit hash for 1.0.9

  network_name = local.vpc_network_name
  create_sg    = false

  labels = local.labels

  public_subnets = [
    for zone in var.zones :
    {
      v4_cidr_blocks = var.subnets[zone]
      zone           = zone
      name           = zone
    }
  ]
}

resource "yandex_vpc_address" "this" {
  for_each = var.zones

  labels = local.labels

  name = length(var.zones) > 1 ? "${local.linux_vm_name}-address-${substr(each.value, -1, 0)}" : "${local.linux_vm_name}-address"
  external_ipv4_address {
    zone_id = each.value
  }
}