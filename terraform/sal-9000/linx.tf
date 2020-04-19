variable "linx_authkey_hash" {}

resource "docker_container" "linx" {
  image = docker_image.linx.latest
  name  = "linx"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/storage/linx"
    container_path = "/data"
  }
  labels = {
    "name" = "linx"
    "traefik.enable" = "true"
    "traefik.http.routers.linx.entrypoints" = "websecure"
    "traefik.http.routers.linx.rule" = "Host(`${cloudflare_record.linx.name}`)"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  upload {
    content = var.linx_authkey_hash
    file = "/authfile"
  }
  command = [
    "-authfile", "/authfile",
    "-basicauth",
    "-maxsize", "4294967296",
    "-maxexpiry", "0",
  ]
}

resource "docker_image" "linx" {
  name = "andreimarcu/linx-server:version-2.3.3"
}

resource "cloudflare_record" "linx" {
  zone_id = var.cloudflare_zone_id
  name    = "i.${var.base_domain}"
  value   = var.ip_address
  type    = "A"
  ttl     = 1
}