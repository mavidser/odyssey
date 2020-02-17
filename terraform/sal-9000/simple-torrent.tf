variable simple_torrent_auth {}

resource "docker_container" "simple-torrent" {
  image = docker_image.simple-torrent.latest
  name  = "simple-torrent"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/simple-torrent"
    container_path = "/downloads"
  }
  labels = {
    "name" = "simple-torrent"
    "traefik.enable" = "true"
    "traefik.http.services.simple-torrent-svc.loadbalancer.server.port" = "3000"
    "traefik.http.routers.simple-torrent-ssl.service" = "simple-torrent-svc"
    "traefik.http.routers.simple-torrent.entrypoints" = "web"
    "traefik.http.routers.simple-torrent.middlewares" = "https-redirect@file"
    "traefik.http.middlewares.simple-torrent-auth.basicauth.users" = var.simple_torrent_auth
    "traefik.http.routers.simple-torrent-ssl.middlewares" = "simple-torrent-auth"
    "traefik.http.routers.simple-torrent-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "simple-torrent" {
  name = "boypt/cloud-torrent:latest"
}
