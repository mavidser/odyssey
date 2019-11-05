variable "name" {}
variable "username" {}
variable "email" {}
variable "hostname" {}
variable "domain" {}
variable "base_domain" {}

provider "docker" {
  version = "2.1.1"
  host = "tcp://docker.${var.domain}:2376/"
  cert_path = "sal-9000/keys/docker"
}

provider "linux" {
  host = "sal-9000.${var.base_domain}"
  user = "root"
}

resource "docker_network" "monitoring" {
  name = "monitoring"
}

resource "docker_network" "mysql" {
  name = "mysql"
}

resource "docker_network" "traefik" {
  name = "traefik"
}
