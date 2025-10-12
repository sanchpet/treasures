locals {
  ig_name             = var.ig_name != null ? var.ig_name : "${var.name_prefix}-ig"
  ig_sa_name          = var.ig_name != null ? "${var.ig_name}-sa" : "${var.name_prefix}-ig-sa"
  zones_list          = tolist(var.zones)
}

data "yandex_compute_image" "this" {
    name = "${var.ig_image_name}-${var.ig_image_tag}"
}

resource "yandex_iam_service_account" "this" {
  name      = local.ig_sa_name
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "compute_editor" {
  folder_id = var.folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.this.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "load-balancer-editor" {
  folder_id = var.folder_id
  role      = "alb.editor"
  member    = "serviceAccount:${yandex_iam_service_account.this.id}"
}

resource "yandex_compute_instance_group" "this" {
  name = local.ig_name
  folder_id = var.folder_id
  service_account_id = yandex_iam_service_account.this.id
  labels = local.labels
  depends_on = [ yandex_resourcemanager_folder_iam_member.compute_editor ]
  instance_template {
    platform_id = "standard-v3"
    name = "${local.ig_name}-instance-{instance.short_id}"
    resources {
      memory = var.instance_resources.memory
      cores  = var.instance_resources.cores
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.this.id
      }
    }
    network_interface {
      network_id = module.net.vpc_id
      subnet_ids = toset([for zone, subnet in module.net.public_subnets : subnet.subnet_id])
    }
    metadata = {
        user-data = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
            ssh_public_key = var.public_ssh_key_path != null ? file(var.public_ssh_key_path) : tls_private_key.this[0].public_key_openssh
        })
    }
  }
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
  allocation_policy {
    zones = var.zones
  }
  deploy_policy {
    max_unavailable = 2
    max_creating = 2
    max_expansion = 2
    max_deleting = 2
  }
  application_load_balancer {
    target_group_name        = "${local.ig_name}-target-group"
    target_group_description = "Network Load Balancer target group for ${local.ig_name} instance group"
    target_group_labels = local.labels
  }
  health_check {
    http_options {
        port = 80
        path = "/"
    }
    interval = 30
  }
}
