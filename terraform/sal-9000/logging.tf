# docker daemon.json:
# "log-opts": {
#   "labels": "name",
#   "tag": "{{.ID}}",
#   "max-size": "10m",
#   "max-file": "3"
# }
resource "docker_container" "loki" {
  image = docker_image.loki.latest
  name  = "loki"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    container_path = "/loki"
    host_path      = "/opt/loki/loki"
  }
  volumes {
    container_path = "/tmp/loki"
    host_path      = "/opt/loki/tmp/loki"
  }
  networks_advanced {
    name = docker_network.monitoring.name
  }
  labels = {
    "name" = "loki"
  }
  command = [
    "-config.file=/etc/loki/local-config.yaml",
  ]
}

resource "docker_container" "promtail" {
  image = docker_image.promtail.latest
  name  = "promtail"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  networks_advanced {
    name = docker_network.monitoring.name
  }
  volumes {
    container_path = "/promtail"
    host_path      = "/opt/promtail"
  }
  volumes {
    container_path = "/var/log"
    host_path      = "/var/log"
    read_only      = true
  }
  volumes {
    container_path = "/dockerlogs"
    host_path      = "/var/lib/docker/containers"
    read_only      = true
  }
  upload {
    content = file("${path.module}/config/logging/promtail.yaml")
    file = "/etc/promtail/config.yaml"
  }
  labels = {
    "name" = "promtail"
  }
  command = [
    "-config.file=/etc/promtail/config.yaml",
  ]
}

resource "docker_image" "loki" {
  name = "grafana/loki:v0.3.0"
}

resource "docker_image" "promtail" {
  name = "grafana/promtail:v0.3.0"
}
