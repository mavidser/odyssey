variable radarr_auth {}

resource "docker_container" "radarr" {
  image = docker_image.radarr.latest
  name  = "radarr"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/radarr/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/media/warp_drive/data/torrents/downloads"
    container_path = "/downloads"
  }
  volumes {
    host_path = "/media/warp_drive/public/media/movies"
    container_path = "/movies"
  }
  labels = {
    "name" = "radarr"
    "traefik.enable" = "true"
    "traefik.http.routers.radarr.entrypoints" = "web"
    "traefik.http.routers.radarr.middlewares" = "https-redirect@file"
    "traefik.http.middlewares.radarr-auth.basicauth.users" = var.radarr_auth
    "traefik.http.routers.radarr-ssl.middlewares" = "radarr-auth"
    "traefik.http.routers.radarr-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "radarr" {
  name = "linuxserver/radarr:arm32v7-5.14"
}
