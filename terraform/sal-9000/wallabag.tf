variable wallabag_secret {}

resource "docker_container" "wallabag" {
  image = docker_image.wallabag.latest
  name  = "wallabag"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/wallabag/data"
    container_path = "/var/www/wallabag/data"
  }
  volumes {
    host_path = "/opt/wallabag/images"
    container_path = "/var/www/wallabag/web/assets/images"
  }
  labels = {
    "name" = "wallabag"
    "traefik.enable" = "true"
    "traefik.http.routers.wallabag.entrypoints" = "web"
    "traefik.http.routers.wallabag.middlewares" = "https-redirect@file"
    "traefik.http.routers.wallabag-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  env = [
    "SYMFONY__ENV__FOSUSER_REGISTRATION=false",
    "SYMFONY__ENV__SECRET=${var.wallabag_secret}",
    "SYMFONY__ENV__DOMAIN_NAME=https://wallabag.${var.domain}"
  ]
}

resource "docker_image" "wallabag" {
  name = "wallabag/wallabag:2.3.8"
}
