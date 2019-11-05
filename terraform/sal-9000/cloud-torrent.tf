variable cloud_torrent_auth {}

resource "docker_container" "cloud-torrent" {
  image = docker_image.cloud-torrent.latest
  name  = "cloud-torrent"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/cloud-torrent"
    container_path = "/downloads"
  }
  labels = {
    "name" = "cloud-torrent"
    "traefik.enable" = "true"
    "traefik.http.services.cloud-torrent-svc.loadbalancer.server.port" = "3000"
    "traefik.http.routers.cloud-torrent-ssl.service" = "cloud-torrent-svc"
    "traefik.http.routers.cloud-torrent.entrypoints" = "web"
    "traefik.http.routers.cloud-torrent.middlewares" = "https-redirect@file"
    "traefik.http.middlewares.cloud-torrent-auth.basicauth.users" = var.cloud_torrent_auth
    "traefik.http.routers.cloud-torrent-ssl.middlewares" = "cloud-torrent-auth"
    "traefik.http.routers.cloud-torrent-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "cloud-torrent" {
  name = "jpillora/cloud-torrent:latest"
}
