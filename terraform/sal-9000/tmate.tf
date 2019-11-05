resource "docker_container" "tmate" {
  image = docker_image.tmate.latest
  name  = "tmate"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  upload {
    content = file("${path.module}/keys/tmate/ssh_host_ecdsa_key")
    file = "/tmate-slave/keys/ssh_host_ecdsa_key"
  }
  upload {
    content = file("${path.module}/keys/tmate/ssh_host_ecdsa_key.pub")
    file = "/tmate-slave/keys/ssh_host_ecdsa_key.pub"
  }
  upload {
    content = file("${path.module}/keys/tmate/ssh_host_rsa_key")
    file = "/tmate-slave/keys/ssh_host_rsa_key"
  }
  upload {
    content = file("${path.module}/keys/tmate/ssh_host_rsa_key.pub")
    file = "/tmate-slave/keys/ssh_host_rsa_key.pub"
  }
  ports {
    internal = 2222
    external = 2222
  }
  labels = {
    "name" = "tmate"
  }
  env = [
    "HOST=tmate.${var.domain}",
    "PORT=2222",
  ]
  capabilities {
    add = ["SETUID", "SETGID", "SYS_CHROOT", "SYS_ADMIN"]
  }
}

resource "docker_image" "tmate" {
  name = "nicopace/tmate-docker:latest"
}
