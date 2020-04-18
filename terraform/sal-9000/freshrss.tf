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
    "traefik.http.routers.freshrss.entrypoints" = "websecure"
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
  name = "freshrss/freshrss:1.16.0"
}
