terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}
provider "aws" {
    region = "us-west-2"
}
variable "tcp_ports" {
 description = "This is a variable of type list"
 type        = list(number)
 default     = [80, 5432, 8000, 22]
}

resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "Ansible-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Ansible-Gateway"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "subnet1"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "subnet2"
  }
}
resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "subnet3"
  }
}

resource "aws_security_group" "ingress_rule_tcp" {
  name        = "Ansible-Security-Group"
  description = "Ansible Create policy"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Ansible-Security-Group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_tcp" {
  count = length(var.tcp_ports)
  security_group_id = aws_security_group.ingress_rule_tcp.id
  description = "Allow ${var.tcp_ports[count.index]} traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port     = var.tcp_ports[count.index]
  to_port     = var.tcp_ports[count.index]
  tags = {
    Name = "allow traffic for tcp protocols"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "main"
  }
}
resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}
