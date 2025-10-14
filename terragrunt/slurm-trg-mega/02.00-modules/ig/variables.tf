variable "yc_region" {
  description = "Yandex Cloud region"
  type        = string
  default     = "ru-central1"
}

variable "yc_availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"
  ]
}

variable "labels" {
  description = "Map of labels"
  type        = map(string)
  default = {
    project = "ig"
    env     = "demo"
  }
}

variable "image_id" {
  description = "Image ID for instance group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for instance group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet ids for instance group"
  type        = list(string)
}

variable "ig_name" {
  description = "Name for instance group"
  type        = string
}
