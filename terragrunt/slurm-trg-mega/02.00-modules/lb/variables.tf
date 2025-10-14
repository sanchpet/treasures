variable "lb_name" {
  description = "Load balancer name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for load balancer"
  type        = string
}

variable "subnets" {
  description = "List of subnets for load balancer"
  type = list(object({
    id   = string
    zone = string
  }))
}

variable "labels" {
  description = "Map of labels"
  type        = map(string)
  default = {
    project = "ig"
    env     = "demo"
  }
}

variable "target_group_ids" {
  description = "List of target group IDs for load balancer"
  type        = list(string)
}
