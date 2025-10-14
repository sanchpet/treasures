include "account" {
  path = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "tfr://registry.terraform.io/hamnsk/vpc/yandex?version=0.5.0"
}

inputs = {
  yc_folder_id = get_env("YC_FOLDER_ID")
  nat_instance = true
  name = include.account.locals.environment
}
