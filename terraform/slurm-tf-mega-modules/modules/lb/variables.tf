variable "labels" {
  type = map(string)
  default = {
    project = "ig"
    env     = "demo"
  }
}

variable "lb_name" {
  description = "Name of loadbalancer"
  type = string
}

variable "subnets" {
  description = "List of subnet objects"
  type = list(object({
    id = string
    zone = string
  }))
}

variable "vpc_id" {
  description = "VPC ID of loadbalancer"
  type = string
}

variable "target_group_ids" {
  description = "List of target groups IDs"
  type = list(string)
}
