resource "docker_container" "haproxy" {
  image = docker_image.haproxy.latest
  name  = "haproxy"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  upload {
    content = templatefile("${path.module}/config/haproxy/haproxy.cfg", {
      sal_ip_address = var.ip_address
    })
    file = "/usr/local/etc/haproxy/haproxy.cfg"
  }
  labels = {
    "name" = "haproxy"
  }
  network_mode = "host"
}

resource "docker_image" "haproxy" {
  name = "haproxy:2.0.5"
}
