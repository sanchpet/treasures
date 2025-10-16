resource "yandex_compute_instance_group" "this" {
  name = var.ig_name

  service_account_id = yandex_iam_service_account.this.id


  instance_template {

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      initialize_params {
        image_id = "fd82tb3u07rkdkfte3dn"
        size     = 10
      }
    }

    network_interface {
      network_id         = var.vpc_id
      subnet_ids         = var.subnet_ids
      security_group_ids = [yandex_vpc_security_group.this.id]
    }

    metadata = {
      ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
    }

    labels = var.labels
  }


  allocation_policy {
    zones = var.yc_availability_zones
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 5
    max_expansion   = 2
    max_deleting    = 2
  }

  application_load_balancer {}

  depends_on = [
    yandex_resourcemanager_folder_iam_member.this
  ]

}
