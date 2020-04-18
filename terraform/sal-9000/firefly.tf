variable firefly_app_key {}
variable mysql_firefly_password {}

resource "docker_container" "firefly" {
  image = docker_image.firefly.latest
  name  = "firefly"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/firefly/storage"
    container_path = "/var/www/firefly-iii/storage"
  }
  labels = {
    "name" = "firefly"
    "traefik.enable" = "true"
    "traefik.http.routers.firefly.entrypoints" = "websecure"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.mysql.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  env = [
    "TRUSTED_PROXIES=**",
    "APP_ENV=local",
    "APP_KEY=${var.firefly_app_key}",
    "DB_CONNECTION=mysql",
    "DB_HOST=${docker_container.mysql.name}",
    "DB_DATABASE=${mysql_database.firefly.name}",
    "DB_USERNAME=${mysql_user.firefly.user}",
    "DB_PASSWORD=${var.mysql_firefly_password}",
  ]
}

resource "docker_image" "firefly" {
  name = "jc5x/firefly-iii:release-5.2.2"
}

resource "mysql_database" "firefly" {
  name = "firefly"
}

resource "mysql_user" "firefly" {
  user               = "firefly"
  host               = "%"
  plaintext_password = var.mysql_firefly_password
}

resource "mysql_grant" "firefly" {
  user       = mysql_user.firefly.user
  host       = mysql_user.firefly.host
  database   = mysql_database.firefly.name
  privileges = ["ALL"]
}
