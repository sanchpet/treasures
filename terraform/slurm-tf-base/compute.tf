locals {
  boot_disk_name      = var.boot_disk_name != null ? var.boot_disk_name : "${var.name_prefix}-boot-disk"
  linux_vm_name       = var.linux_vm_name != null ? var.linux_vm_name : "${var.name_prefix}-linux-vm"
  zones_list = tolist(var.zones)
}

data "yandex_compute_image" "ubuntu-2404-latest" {
  family = "ubuntu-2404-lts"
}

resource "yandex_compute_disk" "boot_disk" {
  count = var.vm_count

  name     = var.vm_count > 1 ? "${local.boot_disk_name}-${substr(local.zones_list[count.index % length(local.zones_list)], -1, 0)}-${floor(count.index / length(local.zones_list))}" : local.boot_disk_name
  zone     = local.zones_list[count.index % length(local.zones_list)]
  image_id = data.yandex_compute_image.ubuntu-2404-latest.id

  labels = local.labels
  
  type = var.instance_resources.disk.disk_type
  size = var.instance_resources.disk.disk_size
}

resource "yandex_compute_instance" "vm" {
  count = var.vm_count

  name                      = length(var.zones) > 1 ? "${local.linux_vm_name}-${substr(local.zones_list[count.index % length(local.zones_list)], -1, 0)}-${floor(count.index / length(local.zones_list))}" : local.linux_vm_name
  allow_stopping_for_update = true
  platform_id               = var.instance_resources.platform_id
  zone                      = local.zones_list[count.index % length(local.zones_list)]
  metadata = {
    user-data = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
        ssh_public_key = var.public_ssh_key_path != null ? file(var.public_ssh_key_path) : tls_private_key.ed25519[0].public_key_openssh
    })
  }
  labels = local.labels

  resources {
    cores  = var.instance_resources.cores
    memory = var.instance_resources.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk[count.index].id
  }

  network_interface {
    subnet_id = {
      for subnet in module.net.public_subnets :
      subnet.zone => subnet.subnet_id
    }[local.zones_list[count.index % length(local.zones_list)]]
    nat            = true
    nat_ip_address = yandex_vpc_address.vm[count.index].external_ipv4_address[0].address
  }
}
