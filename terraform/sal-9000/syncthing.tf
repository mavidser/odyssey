resource "docker_container" "syncthing" {
  image = docker_image.syncthing.latest
  name  = "syncthing"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  labels = {
    "name" = "syncthing"
    "traefik.enable" = "true"
    "traefik.http.routers.syncthing.entrypoints" = "websecure"
    "traefik.http.services.syncthing.loadbalancer.server.port" = "8384"
    "traefik.docker.network" = docker_network.traefik.name
  }
  ports {
    internal = 22000
    external = 22000
  }
  ports {
    internal = 21027
    external = 21027
    protocol = "udp"
  }
  volumes {
    host_path = "/opt/syncthing/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/storage/syncthing/data"
    container_path = "/data"
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_image" "syncthing" {
  name = "linuxserver/syncthing:v1.2.1-ls16"
}
