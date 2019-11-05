variable lounge_password {}

resource "docker_container" "lounge" {
  image = docker_image.lounge.latest
  name  = "lounge"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/lounge"
    container_path = "/config"
  }
  upload {
    content = file("${path.module}/config/lounge/config.js")
    file = "/config/config.js"
  }
  upload {
    content = templatefile("${path.module}/config/lounge/users/root.json.tmpl", {
      znc_server = "znc.${var.domain}"
      username = var.username
      name = var.name
      lounge_password = var.lounge_password
      znc_password_plaintext = var.znc_password_plaintext
      primary_irc_networks = var.primary_irc_networks
    })
    file = "/config/users/root.json"
  }
  labels = {
    "name" = "lounge"
    "traefik.enable" = "true"
    "traefik.http.routers.lounge.entrypoints" = "web"
    "traefik.http.routers.lounge.middlewares" = "https-redirect@file"
    "traefik.http.routers.lounge-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "lounge" {
  name = "linuxserver/thelounge:3.2.0-ls20"
}
