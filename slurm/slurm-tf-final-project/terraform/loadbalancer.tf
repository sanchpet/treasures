locals {
  nlb_name       = var.nlb_name != null ? var.nlb_name : "${var.name_prefix}-nlb"
}

resource "yandex_alb_load_balancer" "this" {
  name = local.nlb_name
  labels = local.labels

  network_id = module.net.vpc_id

  allocation_policy {
    dynamic "location" {
      for_each = var.zones

      content {
        zone_id   = location.value
        subnet_id = {
          for subnet in module.net.public_subnets :
          subnet.zone => subnet.subnet_id
        }[location.value]          
      }
    }
  }

  listener {
    name = "${var.name_prefix}-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.alb.external_ipv4_address[0].address
        }
      }
      ports = [8080]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.this.id
      }
    }
  }
}

resource "yandex_alb_backend_group" "this" {
  name = "${var.name_prefix}-backend-group"
  labels = local.labels

  http_backend {
    name             = "${var.name_prefix}-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_compute_instance_group.this.application_load_balancer[0].target_group_id}"]
    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthcheck_port = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "this" {
  name   = "${var.name_prefix}-router"
}

resource "yandex_alb_virtual_host" "this" {
  name           = "${var.name_prefix}-vhost"
  http_router_id = yandex_alb_http_router.this.id
  route {
    name = "${var.name_prefix}-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.this.id
      }
    }
  }
}
