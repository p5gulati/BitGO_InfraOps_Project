terraform {
  backend "s3" {
    bucket = "tf-state-locking-bitgo" 
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}
