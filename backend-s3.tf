terraform {
  backend "s3" {
    bucket = "terraform-backend-vpro-27sept"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}