### Datasource
data "yandex_client_config" "client" {}

module "vpc" {
  source       = "hamnsk/vpc/yandex"
  version      = "0.5.0"
  yc_folder_id = data.yandex_client_config.client.folder_id
  name         = var.name
  nat_instance = true
}
