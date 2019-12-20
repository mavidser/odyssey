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
  env = [
    "GF_DEFAULT_INSTANCE_NAME=grafana",
    "GF_SERVER_ROOT_URL=https://grafana.${var.domain}",
    "GF_SMTP_ENABLED=true",
    "GF_SMTP_HOST=${var.odyssey_email_smtp_host}:${var.odyssey_email_smtp_port}",
    "GF_SMTP_USER=${var.odyssey_email_user}",
    "GF_SMTP_FROM_ADDRESS=${var.odyssey_email_user}",
    "GF_SMTP_FROM_NAME=Odyssey - Grafana",
    "GF_SMTP_PASSWORD=${var.odyssey_email_password}",
  ]
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