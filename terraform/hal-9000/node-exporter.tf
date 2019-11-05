resource "docker_container" "node-exporter" {
  image = docker_image.node-exporter.latest
  name  = "node-exporter"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path      = "/proc"
    container_path = "/host/proc"
  }
  volumes {
    host_path      = "/sys"
    container_path = "/host/sys"
  }
  volumes {
    host_path      = "/"
    container_path = "/host_root"
    read_only      = true
  }
  labels = {
    "name" = "node-exporter"
  }
  command = [
    "--path.procfs=/host/proc",
    "--path.sysfs=/host/sys",
    "--collector.filesystem.ignored-mount-points=\"^/((bin|boot|core|dev|etc|home|lib|media|mnt|opt|proc|root|run|sbin|srv|sys|tmp|usr|var))($$|/)\"",
  ]
  networks_advanced {
    name = docker_network.monitoring.name
  }
}

resource "docker_image" "node-exporter" {
  name = "mavidser/rpi-node-exporter:latest"
}
