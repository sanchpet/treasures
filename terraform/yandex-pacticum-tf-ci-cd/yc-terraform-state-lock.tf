locals {
  name = var.name != null ? var.name : "terraform-bucket-${random_string.bucket_name.result}"
}

resource "random_string" "bucket_name" {
  length  = 8
  special = false
  upper   = false
}

data "yandex_client_config" "client" {}

module "s3" {
  source = "github.com/terraform-yc-modules/terraform-yc-s3.git?ref=9fc2f832875aefb6051a2aa47b5ecc9a7ea8fde5" # Commit hash for 1.0.2

  folder_id = data.yandex_client_config.client.folder_id
  bucket_name = local.name
  sse_kms_key_configuration = {
    name            = "${local.name}-kms"
    description     = "Key for bucket ${local.name}"
    rotation_period = "8760h" # 1год
  }
  server_side_encryption_configuration = {
    enabled = true
    sse_algorithm = "aws:kms"
  }
  versioning = {
    enabled = true
  }
  lifecycle_rule = [ 
    {
      enabled = true
      noncurrent_version_expiration = {
        days = 30
      }
    }
  ]
}

# Назначение роли сервисному аккаунту - ydb
resource "yandex_resourcemanager_folder_iam_member" "sa-editor-ydb" {
  folder_id = data.yandex_client_config.client.folder_id
  role      = "ydb.editor"
  member    = "serviceAccount:${module.s3.storage_admin_service_account_id}"
}

# Создание YDB-базы для блокировки state-файла
resource "yandex_ydb_database_serverless" "database" {
  name        = "${local.name}-ydb"
  location_id = "ru-central1"
}

# Ожидание после создания YDB
resource "time_sleep" "wait_for_database" {
  create_duration = "60s"
  depends_on      = [yandex_ydb_database_serverless.database]
}

# Создание таблицы в YDB для блокировки state-файла
resource "aws_dynamodb_table" "lock_table" {
  name         = "state-lock-table"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  depends_on   = [time_sleep.wait_for_database, yandex_resourcemanager_folder_iam_member.sa-editor-ydb, module.s3]
}

# Создание файла .env с ключами доступа
resource "local_file" "env" {
  content = <<EOH
    export AWS_ACCESS_KEY_ID="${module.s3.storage_admin_access_key}"
    export AWS_SECRET_ACCESS_KEY="${module.s3.storage_admin_secret_key}"
  EOH
  filename = ".env"
}

output "backend_tf" {
  value = <<EOH

terraform {
  backend "s3" {
    region         = "ru-central1"
    bucket         = "${module.s3.bucket_name}"
    key            = "terraform.tfstate"

    dynamodb_table = "${aws_dynamodb_table.lock_table.id}"

    endpoints = {
      s3       = "https://storage.yandexcloud.net",
      dynamodb = "${yandex_ydb_database_serverless.database.document_api_endpoint}"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
EOH
}