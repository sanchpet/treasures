locals {
  pwd         = path_relative_to_include()
  stack       = split("/", local.pwd)[1]
  environment = split("/", local.pwd)[0]
}

inputs = {
  image_id = "fd89n8278rhueakslujo" # Ubuntu 22.04 
}

generate "backend-variables" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.0.0"
      backend "http" {
        address = "${get_env("TF_GITLAB_BACKEND_ADDRESS")}/${local.environment}-${local.stack}"
        username = "${get_env("TF_GITLAB_BACKEND_USERNAME")}"
        password = "${get_env("TF_GITLAB_BACKEND_TOKEN")}"
        lock_address = "${get_env("TF_GITLAB_BACKEND_ADDRESS")}/${local.environment}-${local.stack}/lock"
        unlock_address = "${get_env("TF_GITLAB_BACKEND_ADDRESS")}/${local.environment}-${local.stack}/lock"
        lock_method = "POST"
        unlock_method = "DELETE"
        retry_wait_min = "5"
      }
      required_providers {
        yandex = {
          source  = "yandex-cloud/yandex"
          version = "~> 0.61"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3"
        }
      }
    }
  EOF
}
