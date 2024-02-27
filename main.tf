variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "instance_type" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block[0]
    availability_zone = var.avail_zone[0]
    map_public_ip_on_launch = true
    tags = {
      Name: "${var.env_prefix}-public-subnet-1"
    }
}

resource "aws_subnet" "myapp-subnet-2" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block[1]
    availability_zone = var.avail_zone[1]
    map_public_ip_on_launch = true
    tags = {
      Name: "${var.env_prefix}-public-subnet-2"
    }
}

resource "aws_route_table" "myapp-public-rt" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-public-rt"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_route_table_association" "myapp-rta-subnet-1" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-public-rt.id
}

resource "aws_route_table_association" "myapp-rta-subnet-2" {
  subnet_id = aws_subnet.myapp-subnet-2.id
  route_table_id = aws_route_table.myapp-public-rt.id
}

resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  description = "security group rules for myapp adv.devops project"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name: "${var.env_prefix}-sg"
  }
}

resource "aws_instance" "myapp-server" {
  ami = "ami-0e670eb768a5fc3d4"
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [ aws_security_group.myapp-sg.id ]
  availability_zone = var.avail_zone[0]
  associate_public_ip_address = true
  key_name = "practice"
  
  tags = {
    Name: "${var.env_prefix}-ec2"
  }
}