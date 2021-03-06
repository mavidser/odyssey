variable mysql_mailman_password {}
variable mailman_hyperkitty_api_key {}
variable mailman_secret_key {}
variable mailman_admin_email {}

resource "docker_container" "mailman-core" {
  image = docker_image.mailman-core.latest
  name  = "mailman-core"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  memory = 256
  memory_swap = 1024
  volumes {
    host_path = "/opt/mailman/core"
    container_path = "/opt/mailman/"
  }
  labels = {
    "name" = "mailman-core"
  }
  env = [
    "SMTP_HOST=172.25.195.4",
    "MM_HOSTNAME=172.25.195.2",
    "DATABASE_URL=mysql+pymysql://${mysql_user.mailman.user}:${var.mysql_mailman_password}@mysql/mailman",
    "DATABASE_TYPE=mysql",
    "DATABASE_CLASS=mailman.database.mysql.MySQLDatabase",
    "HYPERKITTY_API_KEY=${var.mailman_hyperkitty_api_key}",
  ]
  networks_advanced {
    name = docker_network.mailman.name
    ipv4_address = "172.25.195.2"
  }
  networks_advanced {
    name = docker_network.mysql.name
  }
  upload {
    content = templatefile("${path.module}/config/mailman/core/mailman-extra.cfg.tmpl", {
      email = var.mailman_admin_email
    })
    file = "/opt/mailman/core/mailman-extra.cfg"
  }
}

resource "docker_container" "mailman-web" {
  image = docker_image.mailman-web.latest
  name  = "mailman-web"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/mailman/web"
    container_path = "/opt/mailman-web-data"
  }
  env = [
    "DATABASE_URL=mysql://${mysql_user.mailman.user}:${var.mysql_mailman_password}@mysql/mailman",
    "DATABASE_TYPE=mysql",
    "HYPERKITTY_API_KEY=${var.mailman_hyperkitty_api_key}",
    "SECRET_KEY=${var.mailman_secret_key}",
    "DYLD_LIBRARY_PATH=/usr/local/mysql/lib/",
    "SMTP_HOST=172.25.195.4",
    "MAILMAN_HOST_IP=172.25.195.2",
    "SERVE_FROM_DOMAIN=lists.${var.base_domain}",
    "DJANGO_ALLOWED_HOSTS=172.25.195.3",
    "UWSGI_STATIC_MAP=/static=/opt/mailman-web-data/static",
    "MAILMAN_ADMIN_USER=${var.username}",
    "MAILMAN_ADMIN_EMAIL=${var.mailman_admin_email}",
  ]
  labels = {
    "name" = "mailman-web"
    "traefik.enable" = "true"
    "traefik.http.routers.mailman-web.entrypoints" = "websecure"
    "traefik.http.routers.mailman-web.rule" = "Host(`lists.${var.base_domain}`)"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.mailman.name
    ipv4_address = "172.25.195.3"
  }
  networks_advanced {
    name = docker_network.mysql.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_container" "exim4" {
  image = docker_image.exim4.latest
  name  = "exim4"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  hostname = "lists.${var.base_domain}"
  volumes {
    host_path = "/opt/mailman/core"
    container_path = "/opt/mailman/core"
  }
  networks_advanced {
    name = docker_network.mailman.name
    ipv4_address = "172.25.195.4"
  }
  ports {
    internal = 25
    external = 25
  }
  upload {
    content = file("${path.module}/config/mailman/exim4/update-exim4.conf.conf")
    file = "/etc/exim4/update-exim4.conf.conf"
  }
  upload {
    content = templatefile("${path.module}/config/mailman/exim4/00_local_macros.tmpl", {
      base_domain = var.base_domain
    })
    file = "/etc/exim4/conf.d/main/00_local_macros"
  }
  upload {
    content = templatefile("${path.module}/config/mailman/exim4/25_mm3_macros.tmpl", {
      base_domain = var.base_domain
    })
    file = "/etc/exim4/conf.d/main/25_mm3_macros"
  }
  upload {
    content = file("${path.module}/config/mailman/exim4/455_mm3_router")
    file = "/etc/exim4/conf.d/router/455_mm3_router"
  }
  upload {
    content = file("${path.module}/config/mailman/exim4/55_mm3_transport")
    file = "/etc/exim4/conf.d/transport/55_mm3_transport"
  }
  upload {
    content = file("${path.module}/keys/mailman/privatekey.pem")
    file = "/etc/exim4/dkim/privatekey.pem"
  }
  labels = {
    name = "exim4"
  }
}

resource "docker_network" "mailman" {
  name = "mailman"
  ipam_config {
    subnet = "172.25.195.0/24"
  }
}

resource "mysql_database" "mailman" {
  name = "mailman"
}

resource "mysql_user" "mailman" {
  user               = "mailman"
  host               = "%"
  plaintext_password = var.mysql_mailman_password
}

resource "mysql_grant" "mailman" {
  user       = mysql_user.mailman.user
  host       = mysql_user.mailman.host
  database   = mysql_database.mailman.name
  privileges = ["ALL"]
}

resource "docker_image" "mailman-core" {
  name = "maxking/mailman-core:0.2.3"
}

resource "docker_image" "mailman-web" {
  name = "maxking/mailman-web:0.2.3"
}

resource "docker_image" "exim4" {
  name = "tianon/exim4:latest"
}

resource "cloudflare_record" "lists" {
  zone_id = var.cloudflare_zone_id
  name    = "lists.${var.base_domain}"
  value   = var.ip_address
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "lists-wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.lists.${var.base_domain}"
  value   = var.ip_address
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "lists-mx" {
  zone_id = var.cloudflare_zone_id
  name    = "lists.${var.base_domain}"
  value   = var.domain
  type    = "MX"
  ttl     = 1
  priority = 10
}

resource "cloudflare_record" "lists-spf" {
  zone_id = var.cloudflare_zone_id
  name    = "lists.${var.base_domain}"
  value   = "v=spf1 ip4:${var.ip_address} ip6:${var.ip6_address} ~all"
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "lists-dmarc" {
  zone_id = var.cloudflare_zone_id
  name    = "_dmarc.lists.${var.base_domain}"
  value   = "v=DMARC1; p=none; fo=1; rua=mailto:${var.mailman_admin_email}"
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "lists-dkim" {
  zone_id = var.cloudflare_zone_id
  name    = "default._domainkey.lists.${var.base_domain}"
  value   = "v=DKIM1; t=y; k=rsa; p=${file("${path.module}/keys/mailman/publickey.pem")}"
  type    = "TXT"
  ttl     = 1
}