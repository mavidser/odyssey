variable mysql_orion_password {}
variable orion_auth {}

resource "docker_container" "orion-web" {
  image = docker_image.orion-web.latest
  name  = "orion-web"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  labels = {
    name = "orion-web"
    "traefik.enable" = "true"
    "traefik.http.routers.orion-web.rule" = "Host(`orion.${var.domain}`)"
    "traefik.http.routers.orion-web-ssl.rule" = "Host(`orion.${var.domain}`)"
    "traefik.http.routers.orion-web.entrypoints" = "web"
    "traefik.http.routers.orion-web.middlewares" = "https-redirect@file"
    "traefik.http.middlewares.orion-web-auth.basicauth.users" = var.orion_auth
    "traefik.http.routers.orion-web-ssl.middlewares" = "orion-web-auth"
    "traefik.http.routers.orion-web-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}

resource "docker_container" "orion-server" {
  image = docker_image.orion-server.latest
  name  = "orion-server"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  labels = {
    name = "orion-server"
    "traefik.enable" = "true"
    "traefik.http.routers.orion-server.rule" = "Host(`orion.${var.domain}`) && PathPrefix(`/api/`)"
    "traefik.http.routers.orion-server-ssl.rule" = "Host(`orion.${var.domain}`) && PathPrefix(`/api/`)"
    "traefik.http.routers.orion-server.entrypoints" = "web"
    "traefik.http.routers.orion-server.middlewares" = "https-redirect@file"
    "traefik.http.middlewares.orion-server-auth.basicauth.users" = var.orion_auth
    "traefik.http.routers.orion-server-ssl.middlewares" = "orion-server-auth"
    "traefik.http.routers.orion-server-ssl.tls.certresolver" = "default"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.mysql.name
  }
  env = [
    "DATABASE_HOST=mysql",
    "DATABASE_PORT=3306",
    "DATABASE_NAME=${mysql_database.orion.name}",
    "DATABASE_USER=${mysql_user.orion.user}",
    "DATABASE_PASSWORD=${var.mysql_orion_password}",
  ]
}

resource "mysql_database" "orion" {
  name = "orion"
}

resource "mysql_user" "orion" {
  user               = "orion"
  host               = "%"
  plaintext_password = var.mysql_orion_password
}

resource "mysql_grant" "orion" {
  user       = mysql_user.orion.user
  host       = mysql_user.orion.host
  database   = mysql_database.orion.name
  privileges = ["ALL"]
}

resource "docker_image" "orion-web" {
  name = "mavidser/orion-web:latest"
}

resource "docker_image" "orion-server" {
  name = "mavidser/orion-server:latest"
}