resource "docker_container" "jellyfin" {
  image = docker_image.jellyfin.latest
  name  = "jellyfin"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/jellyfin/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/opt/jellyfin/cache"
    container_path = "/cache"
  }
  volumes {
    host_path = "/media/warp_drive/public/media"
    container_path = "/media"
  }
  ports {
    internal = 8096
    external = 8096
  }
  labels = {
    "name" = "jellyfin"
    "traefik.enable" = "true"
    "traefik.http.routers.jellyfin.entrypoints" = "websecure"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "jellyfin" {
  name = "jellyfin/jellyfin:10.5.4-arm"
}
