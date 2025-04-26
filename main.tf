provider "aws" {
  region = "us-east-1"
}

# 1 : Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  tags = {
    Name = "myvpc"
  }
}

# 2: Create a public subnet
resource "aws_subnet" "PublicSubnet" {
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block        = var.cidr_pub
}

# 3 : create a private subnet
resource "aws_subnet" "PrivateSubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.cidr_pri
  map_public_ip_on_launch = true

}

# 4 : create IGW
resource "aws_internet_gateway" "myIgw" {
  vpc_id = aws_vpc.myvpc.id
}

# 5 : route Tables for public subnet
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIgw.id
  }
}

# 7 : route table association public subnet 
resource "aws_route_table_association" "PublicRTAssociation" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRT.id
}

resource "aws_s3_bucket" "s3-demo" {
  bucket = "s3-demo-terra22"
  tags = {
    Name        = "s3-demo"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.s3-demo.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.s3-demo.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "s3-demo-terra22"
    key            = "statefile/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}


resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = "repo-demo-2"
  image_tag_mutability = "IMMUTABLE"
  tags = {
    Name = "repo-demo-2"
  }
}

module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "my-lambda-existing-package-local"
  description   = "My lambda function"

  create_package = false

  image_uri    = "539935451710.dkr.ecr.us-east-1.amazonaws.com/repo-demo:3"
  package_type = "Image"
}