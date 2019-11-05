variable "name" {}
variable "username" {}
variable "email" {}
variable "hostname" {}
variable "domain" {}

provider "docker" {
  version = "2.1.1"
  host = "tcp://192.168.0.50:2376/"
  cert_path = "hal-9000/keys/docker"
}

provider "linux" {
  host = "192.168.0.50"
  user = "sid"
}

resource "docker_network" "traefik" {
  name = "traefik"
}

resource "docker_network" "monitoring" {
  name = "monitoring"
}
