variable transmission_auth {}

resource "docker_container" "transmission" {
  image = docker_image.transmission.latest
  name  = "transmission"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/media/warp_drive/data/torrents/downloads"
    container_path = "/downloads"
  }
  volumes {
    host_path = "/media/warp_drive/data/torrents/files"
    container_path = "/torrent_files"
  }
  volumes {
    host_path = "/opt/transmission"
    container_path = "/config"
  }
  upload {
    content = templatefile("${path.module}/config/transmission/settings.json.tmpl", {
      hostname = var.hostname
      domain = var.domain
    })
    file = "/config/settings.json"
  }
  ports {
    internal = 9091
    external = 9091
  }
  ports {
    internal = 51413
    external = 51413
  }
  ports {
    internal = 51413
    external = 51413
    protocol = "udp"
  }
  labels = {
    "name" = "transmission"
    "traefik.enable" = "true"
    "traefik.http.services.transmission-svc.loadbalancer.server.port" = "9091"
    "traefik.http.routers.transmission-ssl.service" = "transmission-svc"
    "traefik.http.routers.transmission.entrypoints" = "web"
    "traefik.http.routers.transmission.middlewares" = "https-redirect@file"
    "traefik.http.middlewares.transmission-auth.basicauth.users" = var.transmission_auth
    "traefik.http.routers.transmission-ssl.middlewares" = "transmission-auth"
    "traefik.http.routers.transmission-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "transmission" {
  name = "linuxserver/transmission:arm32v7-2.94-r1-ls22"
}
