terraform {
   required_providers {
     aws = {
       source = "hashicorp/aws"
       version = "~> 4.0.0"
     }
   }
}

provider "aws" {
   region = "us-east-2"
}
resource "aws_vpc" "myvpc" {
instance_tenancy = "default"
cidr_block = "100.100.0.0/16"
tags = {
      Name = "Unnati-VPC1"
    }
}

### gateway
resource "aws_internet_gateway" "mygw" {
vpc_id = aws_vpc.myvpc.id
tags = {
      Name = "Unnati-VPC1-IGW1"
    }
}
### Route Table
resource "aws_route_table" "myroute1" {
vpc_id = aws_vpc.myvpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.mygw.id
}
}
## Subnet
resource "aws_subnet" "subnet1" {
vpc_id = aws_vpc.myvpc.id
cidr_block = "100.100.100.0/24"
tags = {
      Name = "Unnati-VPC1-subnet1"
    }
}
## Route table Association
resource "aws_route_table_association" "myroute_asso"{
        subnet_id = aws_subnet.subnet1.id
        route_table_id = aws_route_table.myroute1.id
}

## Security Group with HTTP and SSH Access
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

## VM with user data for webserver
resource "aws_instance" "myinstance1" {
  ami = "ami-0b8b44ec9a8f90422"
  instance_type = "t2.micro"
  key_name = "terraform"
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  user_data = "${file("script.sh")}" 
  tags = {
        Name = "Unnati-Kucl"
  }
}

output "host_ip" {
 value = aws_instance.myinstance1.public_ip
}
