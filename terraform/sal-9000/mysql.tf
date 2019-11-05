variable mysql_root_password {}

resource "docker_container" "mysql" {
  image = docker_image.mysql.latest
  name  = "mysql"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  memory = 512
  volumes {
    host_path = "/opt/mysql"
    container_path = "/var/lib/mysql"
  }
  networks_advanced {
    name = docker_network.mysql.name
  }
  labels = {
    "name" = "mysql"
  }
  ports {
    internal = 3306
    external = 3306
  }
  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
  ]
  command = [
    "--version=10.4.7-MariaDB-1",
  ]
}

resource "docker_image" "mysql" {
  name = "mariadb:10.4.7"
}

provider "mysql" {
  version = "1.7.0"
  endpoint = "mysql.${var.domain}:3306"
  username = "root"
  password = var.mysql_root_password
}
