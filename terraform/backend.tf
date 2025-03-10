terraform {
  backend "gcs" {
    bucket  = "tfstate-snapshare-prod-453315"
    prefix  = "terraform/state/prod"
  }
}