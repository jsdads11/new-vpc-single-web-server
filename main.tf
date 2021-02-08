# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A SINGLE EC2 INSTANCE
# This template runs a simple "Hello, World" web server on a single EC2 Instance
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-west-1"
}

# declare a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "tf-My VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "new-vpc-tf-Public Subnet"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "tf-My new VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_vpc_eu_west_1a_public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = {
    Name = "My New ~VPC tf-Public Subnet Route Table."
  }
}

resource "aws_route_table_association" "my_vpc_eu_west_1a_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.my_vpc_eu_west_1a_public.id
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "example" {
  ami                    = "ami-0aef57767f5404a3c"   # ubuntu
  instance_type          = "t2.micro"
  key_name               = "ej-digital-sandbox-keypair-poc"
  #vpc_security_group_ids = [aws_security_group.allow_web.id, aws_security_group.allow_ssh.id]
  vpc_security_group_ids = [aws_security_group.allow_web_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  tags = {
    Name = "terraform-example"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO THE EC2 INSTANCE WEB INBOUND
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "allow_web_ssh" {
  name = "allow-web-ssh-in-example-sg"
  description = "Allow TCP 8080 inbound connections"

  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["217.44.197.50/32"]
  }
  # Outbound defaults from anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh_sg"
  }

}
