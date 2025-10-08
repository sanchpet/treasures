terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.160.0"
    }
  }
  required_version = ">= 1.13"
}

provider "yandex" {
  folder_id                = "b1ggqjn09hovr4bcms3k"
}
