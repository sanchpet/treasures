resource "yandex_vpc_security_group" "this" {
  name       = "${var.ig_name}-ig"
  network_id = var.vpc_id
  ingress {
    protocol       = "TCP"
    description    = "Allows healthchecks from loadbalancer health check address range"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  labels = var.labels
}
