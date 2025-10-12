output "subnet_ids" {
  description = "The IDs of the VPC subnets used by the Yandex Compute instances."
  value = {
    for cidr_block, subnet_info in module.net.public_subnets :
    subnet_info.name => subnet_info.subnet_id
  }
}

output "alb_public_ip_address" {
  description = "The external IP addresses of the NLB."
  value = {
    for listener in yandex_alb_load_balancer.this.listener : 
    listener.name => [for addr_spec in listener.endpoint.0.address.0.external_ipv4_address : addr_spec.address][0]
  }
}

output "generated_private_ssh_key" {
    description = "Generated ssh key"
    value = var.public_ssh_key_path != null ? null : tls_private_key.this[0].private_key_openssh
    sensitive = true
}
