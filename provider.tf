provider "aws" {
  region  = "us-east-1"
  # profile = "sock_shop"
}

terraform {
  backend "s3" {
    bucket       = "sock-shop-bkt-aleyi"
    key          = "infrastructure/terraform.tfstate"
    region       = "us-east-1"
    # profile      = "sock_shop"
    encrypt      = true
    use_lockfile = true
  }
}