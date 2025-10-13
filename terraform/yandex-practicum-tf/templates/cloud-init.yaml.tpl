#cloud-config
datasource:
  Ec2:
    strict_id: false
ssh_pwauth: no
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
        <h1>Endpoints</h1>    
        <p>We have just provisioned YDB. You can connect to it via: <br><b>${ydb_connect_string}</b></p>
        <p>We have just provisioned Yandex Object Storage. You can find it here: <br><b>${bucket_domain_name}</b></p>        
    </body>
    </html>
    EOF
