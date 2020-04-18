variable sonarr_auth {}

resource "docker_container" "sonarr" {
  image = docker_image.sonarr.latest
  name  = "sonarr"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/sonarr/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/media/warp_drive/data/torrents/downloads"
    container_path = "/downloads"
  }
  volumes {
    host_path = "/media/warp_drive/public/media/tv"
    container_path = "/tv"
  }
  labels = {
    "name" = "sonarr"
    "traefik.enable" = "true"
    "traefik.http.routers.sonarr.entrypoints" = "websecure"
    "traefik.http.routers.sonarr.middlewares" = "sonarr-auth"
    "traefik.http.middlewares.sonarr-auth.basicauth.users" = var.sonarr_auth
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "sonarr" {
  name = "linuxserver/sonarr:arm32v7-5.14"
}
