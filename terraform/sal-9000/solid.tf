resource "docker_container" "solid" {
  image = docker_image.solid.latest
  name  = "solid"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  labels = {
    "name" = "solid"
    "traefik.enable" = "true"
    "traefik.tcp.routers.solid.entrypoints" = "websecure"
    "traefik.tcp.routers.solid.rule" = "HostSNI(`solid.${var.domain}`)"
    "traefik.tcp.routers.solid.tls.certresolver" = "default"
    "traefik.tcp.routers.solid.tls.passthrough" = "true"
    "traefik.tcp.services.solid.loadbalancer.server.port" = "8443"
    "traefik.docker.network" = docker_network.traefik.name
  }
  ports {
    internal = 8443
    external = 8443
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "solid" {
  name = "nodesolidserver/node-solid-server:5.2.4"
}
