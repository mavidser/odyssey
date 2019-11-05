resource "docker_container" "rpi-exporter" {
  image = docker_image.rpi-exporter.latest
  name  = "rpi-exporter"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  networks_advanced {
    name = docker_network.monitoring.name
  }
  labels = {
    "name" = "rpi-exporter"
  }
}

resource "docker_image" "rpi-exporter" {
  name = "carlosedp/arm_exporter:arm"
}
