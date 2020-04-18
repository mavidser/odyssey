variable monica_app_key {}
variable mysql_monica_password {}
variable monica_hash_salt {}

resource "docker_container" "monica" {
  image = docker_image.monica.latest
  name  = "monica"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  volumes {
    host_path = "/opt/monica/storage"
    container_path = "/var/www/monica/storage"
  }
  labels = {
    "name" = "monica"
    "traefik.enable" = "true"
    "traefik.http.routers.monica.entrypoints" = "websecure"
    "traefik.docker.network" = docker_network.traefik.name
  }
  networks_advanced {
    name = docker_network.mysql.name
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
  env = [
    "APP_ENV=local",
    "APP_DEBUG=false",
    "APP_KEY=${var.monica_app_key}",
    "HASH_SALT=${var.monica_hash_salt}",
    "HASH_LENGTH=18",
    "APP_URL=https://monica.${var.domain}",
    "DB_CONNECTION=mysql",
    "DB_HOST=${docker_container.mysql.name}",
    "DB_PORT=3306",
    "DB_DATABASE=${mysql_database.monica.name}",
    "DB_USERNAME=${mysql_user.monica.user}",
    "DB_PASSWORD=${var.mysql_monica_password}",
    "DB_PREFIX=",
    "APP_DEFAULT_LOCALE=en",
    "APP_DISABLE_SIGNUP=true",
    "APP_TRUSTED_PROXIES=*",
    "LOG_CHANNEL=single",
    "SENTRY_SUPPORT=false",
    "CHECK_VERSION=true",
    "CACHE_DRIVER=database",
    "SESSION_DRIVER=file",
    "SESSION_LIFETIME=120",
    "QUEUE_DRIVER=sync",
    "DEFAULT_MAX_UPLOAD_SIZE=10240",
    "DEFAULT_MAX_STORAGE_SIZE=512",
    "DEFAULT_FILESYSTEM=public",
    "ALLOW_STATISTICS_THROUGH_PUBLIC_API_ACCESS=false",
    "POLICY_COMPLIANT=false",
    "REQUIRES_SUBSCRIPTION=false",
    "ENABLE_GEOLOCATION=false"
  ]
}

resource "docker_image" "monica" {
  name = "monicahq/monicahq:v2.17.0"
}

resource "mysql_database" "monica" {
  name = "monica"
  default_character_set = "utf8mb4"
  default_collation     = "utf8mb4_unicode_ci"
}

resource "mysql_user" "monica" {
  user               = "monica"
  host               = "%"
  plaintext_password = var.mysql_monica_password
}

resource "mysql_grant" "monica" {
  user       = mysql_user.monica.user
  host       = mysql_user.monica.host
  database   = mysql_database.monica.name
  privileges = ["ALL"]
}
