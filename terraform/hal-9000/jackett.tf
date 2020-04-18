resource "docker_container" "jackett" {
  image = docker_image.jackett.latest
  name  = "jackett"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/jackett/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/media/warp_drive/data/torrents/downloads"
    container_path = "/downloads"
  }
  labels = {
    "name" = "jackett"
    "traefik.enable" = "true"
    "traefik.http.routers.jackett.entrypoints" = "websecure"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "jackett" {
  name = "linuxserver/jackett:arm32v7-v0.11.618-ls22"
}
