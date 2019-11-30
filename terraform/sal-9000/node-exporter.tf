resource "docker_container" "node-exporter" {
  image = docker_image.node-exporter.latest
  name  = "node-exporter"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path      = "/"
    container_path = "/host_root"
    read_only      = true
  }
  labels = {
    "name" = "node-exporter"
  }
  command = [
    "--path.rootfs=/host_root",
  ]
  networks_advanced {
    name = docker_network.monitoring.name
  }
}

resource "docker_image" "node-exporter" {
  name = "prom/node-exporter:v0.18.1"
}
