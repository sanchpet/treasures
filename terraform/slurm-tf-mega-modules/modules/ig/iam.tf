data "yandex_client_config" "client" {}

resource "random_string" "random" {
  length    = 4
  lower     = true
  special   = false
  min_lower = 4
}

resource "yandex_iam_service_account" "this" {
  name = "${var.ig_name}-sa-${random_string.random.result}"
}

resource "yandex_resourcemanager_folder_iam_member" "this" {
  folder_id = data.yandex_client_config.client.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.this.id}"
  role      = "editor"
}
