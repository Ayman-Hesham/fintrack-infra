terraform {
  backend "s3" {
    bucket         = "fintrack-terraform-state-ap-southeast-1"
    key            = "eks/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "fintrack-terraform-lock"
  }
}
