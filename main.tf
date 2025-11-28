provider "aws" {
  region = var.giant
}
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket0997"
    key            = "prod/terraform.tfstate" 
    region         = "ap-south-1"
    encrypt        = true
  }
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Fetch latest RHEL AMI (Red Hat account ID: 309956199498)
data "aws_ami" "rhel_latest" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat official AWS account

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}




resource "aws_security_group" "websg" {
  name        = "web-sg"
  description = "Security group for web server"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu_server" {

  for_each =  {
    ubuntu  = data.aws_ami.ubuntu_latest.id

    redhat = data.aws_ami.rhel_latest.id

  }
  ami                    = each.value
  instance_type          = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.websg.id]
  key_name               = "Redhat_keypair"   # Replace with your actual key pair name

  tags = {
    Name = each.key
    env  = "prod"
  }
}
