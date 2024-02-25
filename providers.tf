terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.38.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "nana-code-terraform-statefile"
    key    = "tf-statefile"
    region = "ap-south-1"
  }
}
