variable "yc_availability_zones" {
  type = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"
  ]
}

variable "labels" {
  type = map(string)
  default = {
    project = "ig"
    env     = "demo"
  }
}

variable "ig_name" {
  description = "Name for instance group"
  type = string
}

variable "vpc_id" {
  description = "VPC ID for instance group"
  type = string
}

variable "subnet_ids" {
  description = "List of subnets for instance group"
  type = list(string)
}
