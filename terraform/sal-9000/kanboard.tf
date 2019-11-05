resource "docker_container" "kanboard" {
  image = docker_image.kanboard.latest
  name  = "kanboard"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/kanboard/data"
    container_path = "/var/www/app/data"
  }
  volumes {
    host_path = "/opt/kanboard/plugins"
    container_path = "/var/www/app/plugins"
  }
  labels = {
    "name" = "kanboard"
    "traefik.enable" = "true"
    "traefik.http.routers.kanboard.entrypoints" = "web"
    "traefik.http.routers.kanboard.middlewares" = "https-redirect@file"
    "traefik.http.routers.kanboard-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "kanboard" {
  name = "kanboard/kanboard:v1.2.10"
}
