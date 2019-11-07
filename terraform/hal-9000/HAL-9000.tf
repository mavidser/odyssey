variable "name" {}
variable "username" {}
variable "email" {}
variable "hostname" {}
variable "domain" {}
variable "base_domain" {}
variable "sal_domain" {}
variable "ip_address" {}

provider "docker" {
  version = "2.1.1"
  host = "tcp://docker.${var.domain}:23760/"
  cert_path = "hal-9000/keys/docker"
}

provider "linux" {
  host = "hal-9000.sidverma.io"
  port = 220
  user = "sid"
}

resource "docker_network" "traefik" {
  name = "traefik"
}

resource "docker_network" "monitoring" {
  name = "monitoring"
}
