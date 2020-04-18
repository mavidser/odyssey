variable dokuwiki_password {}

resource "docker_container" "dokuwiki" {
  image = docker_image.dokuwiki.latest
  name  = "dokuwiki"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path      = "/opt/dokuwiki"
    container_path = "/bitnami"
  }
  labels = {
    "name" = "dokuwiki"
    "traefik.enable" = "true"
    "traefik.http.routers.dokuwiki.entrypoints" = "websecure"
    "traefik.http.routers.dokuwiki.rule" = "Host(`wiki.${var.domain}`)"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  env = [
    "DOKUWIKI_USERNAME=${var.username}",
    "DOKUWIKI_FULL_NAME=${var.name}",
    "DOKUWIKI_PASSWORD=${var.dokuwiki_password}",
    "DOKUWIKI_EMAIL=${var.email}",
    "DOKUWIKI_WIKI_NAME=The Wiki",
  ]
}

resource "docker_image" "dokuwiki" {
  name = "bitnami/dokuwiki:0.20180422.201901061035-r193"
}
