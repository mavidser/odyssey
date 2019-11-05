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
  upload {
    content = templatefile("${path.module}/config/traefik/traefik.toml.tmpl", {
      domain = var.domain
      email = var.sal_acme_email
    })
    file = "/etc/traefik/traefik.toml"
  }
  upload {
    content = file("${path.module}/config/traefik/dynamic.toml")
    file = "/etc/traefik/dynamic.toml"
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
  labels = {
    "name" = "traefik"
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
  name = "traefik:2.0.0-beta1"
}
