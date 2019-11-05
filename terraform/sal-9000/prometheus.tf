resource "docker_container" "prometheus" {
  image = docker_image.prometheus.latest
  name  = "prometheus"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  user = linux_user.prometheus.uid
  upload {
    content = file("${path.module}/config/prometheus/prometheus.yml")
    file = "/etc/prometheus/prometheus.yml"
  }
  volumes {
    host_path      = linux_folder.prometheus.path
    container_path = "/prometheus"
  }
  labels = {
    "name" = "prometheus"
  }
  networks_advanced {
    name = docker_network.monitoring.name
  }
}

resource "docker_image" "prometheus" {
  name = "prom/prometheus:v2.12.0"
}

resource "linux_folder" "prometheus" {
  path = "/opt/prometheus"
  owner = "${linux_user.prometheus.name}:${linux_user.prometheus.name}"
}

resource "linux_user" "prometheus" {
  name = "prometheus"
  uid = "1024"
}