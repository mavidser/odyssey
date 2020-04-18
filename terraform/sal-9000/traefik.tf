variable traefik_auth {}
variable cloudflare_username {}
variable cloudflare_key {}
variable sal_acme_email {}

resource "docker_container" "traefik" {
  image = docker_image.traefik.latest
  name  = "traefik"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    host_path      = "/opt/traefik/acme"
    container_path = "/acme"
  }
  labels = {
    "name" = "traefik"
    "traefik.enable" = "true"
    "traefik.http.routers.traefik.entrypoints" = "websecure"
    "traefik.http.routers.traefik.service" = "api@internal"
    "traefik.http.routers.traefik.middlewares" = "traefik-auth"
    "traefik.http.middlewares.traefik-auth.basicauth.users" = var.traefik_auth
    "traefik.docker.network" = docker_network.traefik.name
  }
  upload {
    content = templatefile("${path.module}/config/traefik/traefik.toml.tmpl", {
      domain = var.domain
      email = var.sal_acme_email
    })
    file = "/etc/traefik/traefik.toml"
  }
  ports {
    internal = 443
    external = 4430
  }
  ports {
    internal = 80
    external = 8000
  }
  ports {
    internal = 6697
    external = 6697
  }
  networks_advanced {
    name = docker_network.monitoring.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  env = [
    "CF_API_EMAIL=${var.cloudflare_username}",
    "CF_API_KEY=${var.cloudflare_key}",
  ]
}

resource "docker_image" "traefik" {
  name = "traefik:2.2.0"
}
