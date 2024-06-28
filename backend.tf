terraform {
  backend "s3" {
    bucket  = "automatic-secret-rotation"
    key     = "terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}