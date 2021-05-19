terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.AWS_Region
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.SECRET_ACCESS_KEY
}

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "prod-gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.prod-gw.id
  }
}

resource "aws_subnet" "subnet-1" {
   vpc_id = aws_vpc.prod-vpc.id
   cidr_block = "10.0.1.0/24"
}

resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_eb_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_network_interface" "web-server-nic" {
    subnet_id = aws_subnet.subnet-1.id
    private_ips = ["10.0.1.25"]
    security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "name" {
    vpc = true
    network_interface = aws_network_interface.web-server-nic.id
    associate_with_private_ip = "10.0.1.25"
    depends_on = [aws_internet_gateway.prod-gw]
}

resource "aws_instance" "web-server-instance" {
    ami = "ami-05f7491af5eef733a"
    instance_type = "t2.micro"
    key_name = var.AWS_SSH_KEY

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
    }
}