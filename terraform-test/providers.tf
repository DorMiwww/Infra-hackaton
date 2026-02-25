terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
  }
  backend "s3" {
    bucket         = "nero-terraform-state78301" # Назва вашого бакета
    key            = "eks/terraform.tfstate"    # Шлях до файлу всередині бакета
    region         = "eu-central-1"
    #dynamodb_table = "terraform-state-locking"  # Назва таблиці DynamoDB
    encrypt        = true
  }
}



provider "aws" {
  region = "eu-central-1" # Оберіть найближчий до вас регіон
}