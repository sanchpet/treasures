locals {
  pwd = path_relative_to_include()
  stack = split("/", local.pwd)[1]
  environment = split("/", local.pwd)[0]
}

inputs = {
  image_id = "fd89n8278rhueakslujo"  # Ubuntu 22.04 
}