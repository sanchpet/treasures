locals {
  nlb_name       = var.nlb_name != null ? var.nlb_name : "${var.name_prefix}-nlb"
}

resource "yandex_lb_network_load_balancer" "my_nlb" {
  name = local.nlb_name
  labels = local.labels

  listener {
    name = "${var.name_prefix}-listener"
    port = var.nlb_listener_port
    target_port = var.nlb_healthcheck.port
    external_address_spec {
        address = yandex_vpc_address.nlb.external_ipv4_address[0].address
        ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.my_tg.id

    healthcheck {
      name = var.nlb_healthcheck.name
      http_options {
        port = var.nlb_healthcheck.port
        path = var.nlb_healthcheck.path
      }
    }
  }
}

resource "yandex_lb_target_group" "my_tg" {
  name      = "${var.name_prefix}-target-group"
  region_id = "ru-central1"
  labels = local.labels

  dynamic "target" {
    for_each = yandex_compute_instance.vm

    content {
        subnet_id = target.value.network_interface[0].subnet_id
        address = target.value.network_interface[0].ip_address
    }
  }
}
