resource "docker_container" "cadvisor" {
  image = docker_image.cadvisor.latest
  name  = "cadvisor"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }
  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
  }
  volumes {
    host_path      = "/sys"
    container_path = "/sys"
    read_only      = true
  }
  volumes {
    host_path      = "/var/lib/docker"
    container_path = "/var/lib/docker"
    read_only      = true
  }
  volumes {
    host_path      = "/dev/disk"
    container_path = "/dev/disk"
    read_only      = true
  }
  labels = {
    "name" = "cadvisor"
  }
  networks_advanced {
    name = docker_network.monitoring.name
  }
}

resource "docker_image" "cadvisor" {
  name = "mavidser/rpi-cadvisor:latest"
}
