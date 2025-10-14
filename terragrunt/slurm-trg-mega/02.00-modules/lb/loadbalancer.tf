resource "yandex_alb_backend_group" "this" {
  name = var.lb_name

  http_backend {
    name             = var.lb_name
    port             = 8080
    target_group_ids = var.target_group_ids

    healthcheck {
      timeout  = "1s"
      interval = "10s"
      http_healthcheck {
        path = "/health"
      }
    }
  }
}

resource "yandex_alb_virtual_host" "this" {
  name           = var.lb_name
  http_router_id = yandex_alb_http_router.this.id

  route {
    name = "demo-http-api"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.this.id
        timeout          = "1s"
      }
    }
  }
}

resource "yandex_alb_http_router" "this" {
  name = "demo-http-router"
}

resource "yandex_alb_load_balancer" "this" {
  name = var.lb_name

  network_id = var.vpc_id

  security_group_ids = [yandex_vpc_security_group.this.id]

  allocation_policy {
    dynamic "location" {
      for_each = var.subnets
      content {
        zone_id   = location.value.zone
        subnet_id = location.value.id
      }
    }
  }

  listener {
    name = "demo-listener-80"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.this.id
      }
    }
  }
}
