provider "aws" {
  region  = "us-east-1"
  profile = "sock_shop_a"
}

terraform {
  backend "s3" {
    bucket       = "sock-shop-teamz33"
    key          = "infrastructure/terraform.tfstate"
    region       = "us-east-1"
    profile      = "sock_shop_a"
    encrypt      = true
    use_lockfile = true
  }
}
