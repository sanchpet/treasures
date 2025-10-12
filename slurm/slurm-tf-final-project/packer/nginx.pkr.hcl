variable "YC_FOLDER_ID" {
  type = string
  default = env("YC_FOLDER_ID")
}

variable "YC_ZONE" {
  type = string
  default = env("YC_ZONE")
}

variable "YC_SUBNET_ID" {
  type = string
  default = env("YC_SUBNET_ID")
}

variable "image_tag" {
  description = "Image version tag"
  type        = string
}

source "yandex" "nginx" {
    folder_id           = "${var.YC_FOLDER_ID}"
    source_image_family = "centos-stream-9-oslogin"
    ssh_username        = "yc-user"
    use_ipv4_nat        = "true"
    image_description   = "Yandex Cloud nginx image"
    image_family        = "my-images"
    image_name          = "nginx-${var.image_tag}"
    subnet_id           = "${var.YC_SUBNET_ID}"
    disk_type           = "network-ssd"
    zone                = "${var.YC_ZONE}"
}

build {
    sources = ["source.yandex.nginx"]

    provisioner "ansible" {
        playbook_file = "ansible/playbook.yml"
    }
}
