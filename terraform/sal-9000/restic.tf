variable restic_b2_repo {}
variable restic_password {}
variable b2_account_id {}
variable b2_account_key {}

resource "docker_container" "restic" {
  image = docker_image.restic.latest
  name  = "restic"
  must_run = true
  destroy_grace_seconds = 30
  restart = "unless-stopped"
  hostname = var.hostname
  volumes {
    host_path      = "/opt"
    container_path = "/data"
    read_only      = "true"
  }
  labels = {
    "name" = "restic"
  }
  env = [
    "RESTIC_REPOSITORY=${var.restic_b2_repo}",
    "RESTIC_PASSWORD=${var.restic_password}",
    "B2_ACCOUNT_ID=${var.b2_account_id}",
    "B2_ACCOUNT_KEY=${var.b2_account_key}",
    "BACKUP_CRON=0 00,12 * * *",
    "RESTIC_FORGET_ARGS=--prune --keep-last 2 --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --keep-yearly 100",
    "RESTIC_JOB_ARGS=--exclude=/data/prometheus --exclude=/data/loki"
  ]
}

resource "docker_image" "restic" {
  name = "lobaro/restic-backup-docker:1.2-0.9.4"
}
