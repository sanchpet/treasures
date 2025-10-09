#cloud-config
datasource:
  Ec2:
    strict_id: false
ssh_pwauth: no
users:
  - name: sanchpet
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4Ekg6KZNE4QcW8gfgKVC824nLDLBALRkZmuyByDbtg sanchpet@DESKTOP-3304RLF
package_update: false
package_upgrade: false
packages:
  - nginx
runcmd: 
  - |
    sudo tee -a /var/www/html/index.nginx-debian.html > /dev/null <<'EOF'
    <!doctype html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Terraform provisioned</title>
    </head>
    <body>
        <h1>Hello</h1>        
    </body>
    </html>
    EOF