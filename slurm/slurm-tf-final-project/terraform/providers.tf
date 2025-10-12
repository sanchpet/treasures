terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.164.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.1.0"
    }
  }
  required_version = ">= 1.13"
}

provider "yandex" {
  folder_id = var.folder_id
}
