variable firefox_sync_secret {}

resource "docker_container" "firefox-sync" {
  image = docker_image.firefox-sync.latest
  name  = "firefox-sync"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  user = "${linux_user.firefox-sync.uid}:${linux_user.firefox-sync.gid}"
  volumes {
    host_path = linux_folder.firefox-sync.path
    container_path = "/tmp"
  }
  labels = {
    "name" = "firefox-sync"
    "traefik.enable" = "true"
    "traefik.http.services.firefox-sync-svc.loadbalancer.server.port" = "5000"
    "traefik.http.routers.firefox-sync-ssl.service" = "firefox-sync-svc"
    "traefik.http.routers.firefox-sync.entrypoints" = "web"
    "traefik.http.routers.firefox-sync.middlewares" = "https-redirect@file"
    "traefik.http.routers.firefox-sync-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  env = [
    "SYNCSERVER_PUBLIC_URL=https://firefox-sync.${var.domain}",
    "SYNCSERVER_SECRET=${var.firefox_sync_secret}",
    "SYNCSERVER_SQLURI=sqlite:////tmp/syncserver.db",
    "SYNCSERVER_BATCH_UPLOAD_ENABLED=true",
    "SYNCSERVER_FORCE_WSGI_ENVIRON=true",
    "SYNCSERVER_ALLOW_NEW_USERS=false",
    "PORT=5000",
  ]
}

resource "docker_image" "firefox-sync" {
  name = "mozilla/syncserver:latest"
}

resource "linux_folder" "firefox-sync" {
  path = "/opt/firefox-sync"
  owner = "${linux_user.firefox-sync.name}:${linux_user.firefox-sync.name}"
}

resource "linux_user" "firefox-sync" {
  name = "firefox-sync"
  uid = "1001"
}