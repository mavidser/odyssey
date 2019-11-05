resource "docker_container" "freshrss" {
  image = docker_image.freshrss.latest
  name  = "freshrss"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path      = "/opt/freshrss"
    container_path = "/var/www/FreshRSS/data"
  }
  labels = {
    "name" = "freshrss"
    "traefik.enable" = "true"
    "traefik.http.routers.freshrss.entrypoints" = "web"
    "traefik.http.routers.freshrss.middlewares" = "https-redirect@file"
    "traefik.http.routers.freshrss-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  env = [
    "CRON_MIN=4,34",
    "TZ=Asia/Kolkata",
  ]
}

resource "docker_image" "freshrss" {
  name = "freshrss/freshrss:1.14.3"
}
