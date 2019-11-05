resource "docker_container" "tinc" {
  image = docker_image.tinc.latest
  name  = "tinc"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  upload {
    content = file("${path.module}/config/tinc/tinc.conf")
    file = "/etc/tinc/tinc.conf"
  }
  upload {
    content = file("${path.module}/config/tinc/tinc-up")
    file = "/etc/tinc/tinc-up"
    executable = true
  }
  upload {
    content = file("${path.module}/config/tinc/tinc-down")
    file = "/etc/tinc/tinc-down"
    executable = true
  }
  upload {
    content = file("${path.module}/keys/tinc/rsa_key.priv")
    file = "/etc/tinc/rsa_key.priv"
  }
  upload {
    content = templatefile("${path.module}/config/tinc/hosts/hal_9000.tmpl", {
      hal_public_key = file("${path.module}/keys/tinc/hal_9000.pub")
    })
    file = "/etc/tinc/hosts/hal_9000"
  }
  upload {
    content = templatefile("${path.module}/config/tinc/hosts/sal_9000.tmpl", {
      sal_public_key = file("${path.module}/keys/tinc/sal_9000.pub")
      domain = var.sal_domain
    })
    file = "/etc/tinc/hosts/sal_9000"
  }
  labels = {
    "name" = "tinc"
  }
  capabilities {
    add = ["NET_ADMIN"]
  }
  network_mode = "host"
  devices {
    host_path = "/dev/net/tun"
  }
}

resource "docker_image" "tinc" {
  name = "jordancrawford/rpi-tinc:latest"
}
