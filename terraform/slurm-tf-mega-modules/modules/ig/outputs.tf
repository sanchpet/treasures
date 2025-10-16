output "target_group_id" {
  description = "Target group ID created by instance group"
  value = yandex_compute_instance_group.this.application_load_balancer.0.target_group_id
}
