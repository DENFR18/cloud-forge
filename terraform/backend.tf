terraform {
  backend "s3" {
    bucket         = "cloud-forge-tfstate"
    key            = "cloud-forge.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "cloud-forge-tflock"
    encrypt        = true
  }
}
