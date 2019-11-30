resource "docker_container" "grafana" {
  image = docker_image.grafana.latest
  name  = "grafana"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  user = linux_user.grafana.uid
  volumes {
    host_path      = linux_folder.grafana.path
    container_path = "/var/lib/grafana"
  }
  labels = {
    "name" = "grafana"
    "traefik.enable" = "true"
    "traefik.http.routers.grafana.entrypoints" = "web"
    "traefik.http.routers.grafana.middlewares" = "https-redirect@file"
    "traefik.http.routers.grafana-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.monitoring.name
  }
}

resource "docker_image" "grafana" {
  name = "grafana/grafana:6.4.4"
}

resource "linux_folder" "grafana" {
  path = "/opt/grafana"
  owner = "${linux_user.grafana.name}:${linux_user.grafana.name}"
}

resource "linux_user" "grafana" {
  name = "grafana"
  uid = "472"
}