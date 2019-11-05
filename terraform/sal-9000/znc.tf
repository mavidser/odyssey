variable znc_password_salt {}
variable znc_password_plaintext {}
variable primary_irc_networks {}

resource "docker_container" "znc" {
  image = docker_image.znc.latest
  name  = "znc"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/znc"
    container_path = "/znc-data"
  }
  upload {
    content = templatefile("${path.module}/config/znc/znc.conf.tmpl", {
      primary_irc_networks = var.primary_irc_networks
      username = var.username
      name = var.name
      znc_password_salt = var.znc_password_salt
      znc_password_hash = sha256("${var.znc_password_plaintext}${var.znc_password_salt}")
      })
    file = "/znc-data/configs/znc.conf"
  }
  upload {
    content = file("${path.module}/config/znc/clientbuffer.cpp")
    file = "/znc-data/modules/clientbuffer.cpp"
  }
  upload {
    content = file("${path.module}/config/znc/playback.cpp")
    file = "/znc-data/modules/playback.cpp"
  }
  labels = {
    "name" = "znc"
    "traefik.enable" = "true"
    "traefik.http.services.znc-svc.loadbalancer.server.port" = "6667"
    "traefik.http.routers.znc-ssl.service" = "znc-svc"
    "traefik.http.routers.znc.rule" = "Host(`znc.${var.domain}`)"
    "traefik.http.routers.znc-ssl.rule" = "Host(`znc.${var.domain}`)"
    "traefik.http.routers.znc.entrypoints" = "web"
    "traefik.http.routers.znc.middlewares" = "https-redirect@file"
    "traefik.http.routers.znc-ssl.tls.certresolver" = "default"
    "traefik.tcp.routers.znc-tls.entrypoints" = "irc"
    "traefik.tcp.routers.znc-tls.tls.certresolver" = "default"
    "traefik.tcp.routers.znc-tls.rule" = "HostSNI(`znc.${var.domain}`)"
    "traefik.tcp.routers.znc-tls.service" = "znc-svc"
    "traefik.tcp.services.znc-svc.loadbalancer.server.port" = "6667"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  ports {
    internal = 6667
    external = 6667
  }
}

resource "docker_image" "znc" {
  name = "znc:1.7.4"
}
