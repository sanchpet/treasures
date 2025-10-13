terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.100"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.44"
    }
  }
  required_version = ">= 1.3.0"
}
provider "aws" {
  region                      = "eu-west-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = module.s3.storage_admin_access_key
  secret_key                  = module.s3.storage_admin_secret_key
  endpoints {
    dynamodb = yandex_ydb_database_serverless.database.document_api_endpoint
  }
}

provider "random" {}
