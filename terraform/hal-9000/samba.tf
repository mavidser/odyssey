variable "samba_password" {}

resource "docker_container" "samba" {
  hostname = var.hostname
  image = docker_image.samba.latest
  name  = "samba"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path      = "/media/warp_drive"
    container_path = "/share/warp_drive"
  }
  ports {
    internal = 137
    external = 137
    protocol = "udp"
  }
  ports {
    internal = 138
    external = 138
    protocol = "udp"
  }
  ports {
    internal = 139
    external = 139
  }
  ports {
    internal = 445
    external = 445
    protocol = "tcp"
  }
  ports {
    internal = 445
    external = 445
    protocol = "udp"
  }
  labels = {
    "name" = "samba"
  }
  command = [
    "-u", "${var.username}:${var.samba_password}",
    "-s", "Warp Drive:/share/warp_drive:rw:${var.username}",
    "-s", "Warp Drive (Public):/share/warp_drive/public:ro:",
  ]
}

resource "docker_image" "samba" {
  name = "mavidser/rpi-samba:latest"
}
