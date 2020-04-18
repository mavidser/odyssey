resource "docker_container" "calibre" {
  image = docker_image.calibre.latest
  name  = "calibre"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/calibre/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/media/warp_drive/public/books"
    container_path = "/books"
  }
  labels = {
    "name" = "calibre"
    "traefik.enable" = "true"
    "traefik.http.routers.calibre.entrypoints" = "websecure"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "calibre" {
  name = "linuxserver/calibre-web:arm32v7-0.6.6-ls53"
}
