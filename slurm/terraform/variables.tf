########### Global settings ###########
variable "name_prefix" {
  description = "(Optional) - Name prefix for project."
  type        = string
  default     = "slurm"
}

variable "zones" {
  description = "(Optional) - Yandex Cloud Zones for provisoned resources."
  type        = set(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

locals {
    labels = {
        "created_by" = "terraform"
        "env"        = "lab"
        "project"    = var.name_prefix
    }
}

############ Network settings ###########

variable "vpc_network_name" {
  description = "(Optional) - Name of the VPC network."
  type        = string
  default     = null
}

variable "subnets" {
  description = "(Optional) - A map of AZ to subnets CIDR block ranges."
  type        = map(list(string))
  default = {
    "ru-central1-a" = ["192.168.10.0/24"],
    "ru-central1-b" = ["192.168.11.0/24"],
    "ru-central1-d" = ["192.168.12.0/24"]    
  }
}

variable "nlb_name" {
  description = "(Optional) - Name of the Network Load Balancer."
  type        = string
  default     = null
}

variable "nlb_listener_port" {
  description = "(Optional) - Listener port of the Network Load Balancer."
  type        = number
  default     = 8080
}

variable "nlb_healthcheck" {
    description = "(Optional) - NLB healthcheck customization"
    type        = object({
      name = optional(string, "http")
      port = optional(number, 80)
      path = optional(string, "/")
    })
    default = {
      name = "http"
      port = 80
      path = "/"
    }
}

############ Compute settings ###########

variable "vm_count" {
  description = "(Optional) - number of virtual machines"
  type = number
  default = 3
}

variable "boot_disk_name" {
  description = "(Optional) - Name of the boot disk."
  type        = string
  default     = null
}

variable "linux_vm_name" {
  description = "(Optional) - Name of the Linux VM."
  type        = string
  default     = null
}

variable "instance_resources" {
  description = <<EOF
    (Optional) Specifies the resources allocated to an instance.
      - `platform_id`: The type of virtual machine to create.If not provided, it defaults to `standard-v3`.
      - `cores`: The number of CPU cores allocated to the instance.
      - `memory`: The amount of memory (in GiB) allocated to the instance.
      - `disk`: Configuration for the instance disk.
        - `disk_type`: The type of disk for the instance. If not provided, it defaults to `network-ssd`.
        - `disk_size`: The size of the disk (in GiB) allocated to the instance. If not provided, it defaults to 15 GiB.
  EOF

  type = object({
    platform_id = optional(string, "standard-v3")
    cores       = number
    memory      = number
    disk = optional(object({
      disk_type = optional(string, "network-ssd")
      disk_size = optional(number, 15)
    }), {})
  })
}

variable "public_ssh_key_path" {
    description = "(Optional) - set the path for your private key"
    type = string
    default = null
}
