variable vscode_password {}

resource "docker_container" "vscode" {
  image = docker_image.vscode.latest
  name  = "vscode"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = linux_folder.vscode_project.path
    container_path = "/home/coder/project"
  }
  volumes {
    host_path = linux_folder.vscode_share.path
    container_path = "/home/coder/.local/share/code-server"
  }
  labels = {
    "name" = "vscode"
    "traefik.enable" = "true"
    "traefik.http.routers.vscode.entrypoints" = "websecure"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  env = [
    "PASSWORD=${var.vscode_password}",
  ]
  command = [
    "--disable-telemetry",
  ]
}

resource "docker_image" "vscode" {
  name = "codercom/code-server:2.1674-vsc1.39.2"
}

resource "linux_folder" "vscode_project" {
  path = "/opt/vscode/project"
  owner = "${linux_user.vscode.name}:${linux_user.vscode.name}"
}

resource "linux_folder" "vscode_share" {
  path = "/opt/vscode/share"
  owner = "${linux_user.vscode.name}:${linux_user.vscode.name}"
}

resource "linux_user" "vscode" {
  name = "coder"
  uid = "1000"
}