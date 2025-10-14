output "public_ip" {
  description = "Public IP to connect"
  value       = module.lb.public_ip
}
