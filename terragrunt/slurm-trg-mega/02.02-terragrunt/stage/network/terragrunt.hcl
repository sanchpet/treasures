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
  subnets = [
    {
      "v4_cidr_blocks": [
        "10.130.0.0/24"
      ],
      "zone": "ru-central1-a"
    },
    {
      "v4_cidr_blocks": [
        "10.129.0.0/24"
      ],
      "zone": "ru-central1-b"
    },
    {
      "v4_cidr_blocks": [
        "10.128.0.0/24"
      ],
      "zone": "ru-central1-d"
    }
  ]
}
