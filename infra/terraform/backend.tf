terraform {
  backend "s3" {
    bucket       = "capstone-phoenix-tfstate"
    key          = "capstone/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}