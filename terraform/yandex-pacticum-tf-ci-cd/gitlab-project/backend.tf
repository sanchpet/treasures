terraform {
  backend "s3" {
    region         = "ru-central1"
    bucket         = "sanchpet-gitlab-ci-cd"
    key            = "terraform.tfstate"

    dynamodb_table = "state-lock-table"

    endpoints = {
      s3       = "https://storage.yandexcloud.net",
      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gr5nrg10c4rnr8gehu/etncrnig6eqsd6dma3h4"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}