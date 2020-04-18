variable radicale_auth {}

resource "docker_container" "radicale" {
  image = docker_image.radicale.latest
  name  = "radicale"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/radicale/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/opt/radicale/data"
    container_path = "/data"
  }
  upload {
    content = file("${path.module}/config/radicale/config")
    file = "/config/config"
  }
  upload {
    content = var.radicale_auth
    file = "/config/auth"
  }
  labels = {
    "name" = "radicale"
    "traefik.enable" = "true"
    "traefik.http.routers.radicale.entrypoints" = "websecure"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "radicale" {
  name = "tomsquest/docker-radicale:amd64.2.1.11.1"
}
