locals {
  boot_disk_name      = var.boot_disk_name != null ? var.boot_disk_name : "${var.name_prefix}-boot-disk"
  linux_vm_name       = var.linux_vm_name != null ? var.linux_vm_name : "${var.name_prefix}-linux-vm"
}

data "yandex_compute_image" "ubuntu-2404-latest" {
  family = "ubuntu-2404-lts"
}

resource "yandex_compute_disk" "boot_disk" {
  for_each = var.zones

  name     = length(var.zones) > 1 ? "${local.boot_disk_name}-${substr(each.value, -1, 0)}" : local.boot_disk_name
  zone     = each.value
  image_id = data.yandex_compute_image.ubuntu-2404-latest.id

  labels = local.labels
  
  type = var.instance_resources.disk.disk_type
  size = var.instance_resources.disk.disk_size
}

resource "yandex_compute_instance" "vm" {
  for_each = var.zones

  name                      = length(var.zones) > 1 ? "${local.linux_vm_name}-${substr(each.value, -1, 0)}" : local.linux_vm_name
  allow_stopping_for_update = true
  platform_id               = var.instance_resources.platform_id
  zone                      = each.value
  metadata = {
    user-data = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {})
  }
  labels = local.labels

  resources {
    cores  = var.instance_resources.cores
    memory = var.instance_resources.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk[each.value].id
  }

  network_interface {
    subnet_id = {
      for subnet in module.net.public_subnets :
      subnet.zone => subnet.subnet_id
    }[each.value]
    nat            = true
    nat_ip_address = yandex_vpc_address.this[each.value].external_ipv4_address[0].address
  }
}
