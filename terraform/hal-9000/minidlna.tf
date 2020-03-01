resource "docker_container" "minidlna" {
  image = docker_image.minidlna.latest
  name  = "minidlna"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/media/warp_drive/public/media"
    container_path = "/opt/Videos"
  }
  volumes {
    host_path = "/tmp/music"
    container_path = "/opt/Music"
  }
  volumes {
    host_path = "/tmp/pictures"
    container_path = "/opt/Pictures"
  }
  volumes {
    host_path = "/opt/minidlna"
    container_path = "/var/cache/minidlna"
  }
  tmpfs = {
    "/run" = "rw"
  }
  upload {
    content = file("${path.module}/config/minidlna/minidlna.conf")
    file = "/etc/minidlna.conf"
  }
  labels = {
    "name" = "minidlna"
  }
  network_mode = "host"
}

resource "docker_image" "minidlna" {
  name = "mavidser/rpi-minidlna:latest"
}
