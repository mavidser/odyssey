variable "httptunnel_clients" {}

resource "docker_container" "httptunnel" {
  image = docker_image.httptunnel.latest
  name  = "httptunnel"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  upload {
    content = file("${path.module}/keys/httptunnel/server.key")
    file = "/certs/server.key"
  }
  upload {
    content = file("${path.module}/keys/httptunnel/server.crt")
    file = "/certs/server.crt"
  }
  labels = {
    "name" = "httptunnel"
    "traefik.enable" = "true"
    "traefik.http.routers.httptunnel.entrypoints" = "websecure"
    "traefik.http.routers.httptunnel.rule" = "HostRegexp(`tun.${var.domain}`, `{subdomain:[a-z0-9-]+}.tun.${var.domain}`)"
    "traefik.http.routers.httptunnel.tls.domains[0].main" = "tun.${var.domain}"
    "traefik.http.routers.httptunnel.tls.domains[0].sans" = "*.tun.${var.domain}"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  command = [
    "-tlsCrt", "/certs/server.crt",
    "-tlsKey", "/certs/server.key",
    "-clients", var.httptunnel_clients,
  ]
  ports {
    internal = 5223
    external = 5223
  }
}

resource "docker_image" "httptunnel" {
  name = "mavidser/go-http-tunnel:latest"
}
