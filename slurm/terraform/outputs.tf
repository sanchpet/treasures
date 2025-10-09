output "boot_disk_ids" {
  description = "The IDs of the boot disks created for the instances."
  value = {
    for disk in yandex_compute_disk.boot_disk :
    disk.name => disk.id...
  }
}

output "instance_ids" {
  description = "The IDs of the Yandex Compute instances."
  value = {
    for instance in yandex_compute_instance.vm :
    instance.name => instance.id...
  }
}

output "subnet_ids" {
  description = "The IDs of the VPC subnets used by the Yandex Compute instances."
  value = {
    for cidr_block, subnet_info in module.net.public_subnets :
    subnet_info.name => subnet_info.subnet_id
  }
} 

output "instance_public_ip_addresses" {
  description = "The external IP addresses of the instances."
  value = {
    for address in yandex_vpc_address.this :
    address.name => address.external_ipv4_address[0].address...
  }
}

output "nlb_public_ip_address" {
  description = "The external IP addresses of the NLB."
  value = {
    for listener in yandex_lb_network_load_balancer.my_nlb.listener : 
    listener.name => [for addr_spec in listener.external_address_spec : addr_spec.address][0]
  }
}
