variable "name" {}
variable "username" {}
variable "email" {}
variable "hostname" {}
variable "domain" {}
variable "base_domain" {}
variable "hal_domain" {}
variable "ip_address" {}
variable "ip6_address" {}
variable "cloudflare_zone_id" {}
variable odyssey_email_user {}
variable odyssey_email_smtp_host {}
variable odyssey_email_smtp_port {}
variable odyssey_email_password {}

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

resource "cloudflare_record" "sal-9000" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain
  value   = var.ip_address
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "sal-9000-wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.${var.domain}"
  value   = var.ip_address
  type    = "A"
  ttl     = 1
}