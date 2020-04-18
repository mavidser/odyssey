variable "name" {}
variable "username" {}
variable "email" {}
variable "hostname" {}
variable "domain" {}
variable "base_domain" {}
variable "sal_domain" {}
variable "ip_address" {}
variable "cloudflare_zone_id" {}
variable odyssey_email_user {}
variable odyssey_email_smtp_host {}
variable odyssey_email_smtp_port {}
variable odyssey_email_password {}

provider "docker" {
  version = "2.1.1"
  host = "ssh://sid@hal-9000.local:22"
}

provider "linux" {
  host = "hal-9000.local"
  port = 22
  user = "sid"
}

resource "docker_network" "traefik" {
  name = "traefik"
}

resource "docker_network" "monitoring" {
  name = "monitoring"
}

resource "cloudflare_record" "hal-9000" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain
  value   = var.ip_address
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "hal-9000-wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.${var.domain}"
  value   = var.ip_address
  type    = "A"
  ttl     = 1
}