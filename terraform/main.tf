terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

provider "aws" {
   region     = var.region
   profile = "default"

}
# <<==>> create the vpc <<==>>

resource "aws_vpc" "jenkins-vpc" {
  cidr_block = var.vpc_cider_block

  tags = {
    Name = "jenkins-vpc"
  }
  
}

# <<==>> create public subnet <<==>>

resource "aws_subnet" "subnet_1" {
  vpc_id = aws_vpc.jenkins-vpc.id
  cidr_block = var.subnet_cider_block  
  availability_zone = var.availability_zone

  tags = {
    Name = "jenkins-subnet"
  }
}


resource "aws_internet_gateway" "jenkins-igw" {
  vpc_id = aws_vpc.jenkins-vpc.id

  
  tags = {
    Name = "jenkins-igw"
  }
  
}

resource "aws_route_table" "jenkins-rtb" {
  vpc_id = aws_vpc.jenkins-vpc.id

  route  {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.jenkins-igw.id
  }

  tags = {
    Name = "jenkins-rtb"
  }
  
}
resource "aws_route_table_association" "jenkins-rtba" {
  route_table_id = aws_route_table.jenkins-rtb.id
  subnet_id = aws_subnet.subnet_1.id
  
}