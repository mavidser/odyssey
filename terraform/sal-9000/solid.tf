resource "docker_container" "solid" {
  image = docker_image.solid.latest
  name  = "solid"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  user = "root:root"
  labels = {
    "name" = "solid"
    "traefik.enable" = "true"
    "traefik.tcp.routers.solid.entrypoints" = "websecure"
    "traefik.tcp.routers.solid.rule" = "HostSNI(`${cloudflare_record.solid.name}`)"
    "traefik.tcp.routers.solid.tls.passthrough" = "true"
    "traefik.tcp.services.solid.loadbalancer.server.port" = "8443"
    "traefik.docker.network" = docker_network.traefik.name
  }
  ports {
    internal = 8443
    external = 8443
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  volumes {
    host_path = "/opt/solid/cert/archive/${cloudflare_record.solid.name}"
    container_path = "/certs"
    read_only = "true"
  }
  volumes {
    host_path = "/opt/solid/data"
    container_path = "/opt/solid/data"
  }
  env = [
    "SOLID_SSL_KEY=/certs/privkey1.pem",
    "SOLID_SSL_CERT=/certs/fullchain1.pem",
  ]
  command = [
    "start",
    "--server-uri", "https://${cloudflare_record.solid.name}",
  ]
}

resource "docker_image" "solid" {
  name = "nodesolidserver/node-solid-server:5.2.4"
}

resource "docker_container" "solid-cert" {
  image = docker_image.solid-cert.latest
  name  = "solid-cert"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  upload {
    content = <<-EOT
    dns_cloudflare_email = ${var.cloudflare_username}
    dns_cloudflare_api_key = ${var.cloudflare_key}
    EOT
    file = "/cloudflare.ini"
  }
  volumes {
    host_path = "/opt/solid/cert"
    container_path = "/etc/letsencrypt"
  }
  command = [
    "certonly",
    "--dns-cloudflare",
    "--dns-cloudflare-credentials", "/cloudflare.ini",
    "-d", "${cloudflare_record.solid.name}",
    "--email", "${var.sal_acme_email}",
    "--agree-tos",
    "--server", "https://acme-v02.api.letsencrypt.org/directory",
  ]
}

resource "docker_image" "solid-cert" {
  name = "certbot/dns-cloudflare:v1.3.0"
}

resource "cloudflare_record" "solid" {
  zone_id = var.cloudflare_zone_id
  name    = "solid.${var.base_domain}"
  value   = var.ip_address
  type    = "A"
  ttl     = 1
}