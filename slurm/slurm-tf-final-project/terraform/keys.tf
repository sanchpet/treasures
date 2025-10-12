resource "tls_private_key" "this" {
    count = var.public_ssh_key_path != null ? 0 : 1
    algorithm = "ED25519"
}
