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

resource "yandex_vpc_address" "vm" {
  count = var.vm_count

  labels = local.labels

  name = var.vm_count > 1 ? "${local.linux_vm_name}-address-${substr(local.zones_list[count.index % length(local.zones_list)], -1, 0)}-${floor(count.index / length(local.zones_list))}" : "${local.linux_vm_name}-address"
  external_ipv4_address {
    zone_id = local.zones_list[count.index % length(local.zones_list)]
  }
}

resource "yandex_vpc_address" "nlb" {
    labels = local.labels
    name = "${var.name_prefix}-nlb-address"
  external_ipv4_address {
    zone_id = "ru-central1-d"
  }
}
