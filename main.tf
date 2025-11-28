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

  for_each {
    ubuntu  = "ami-04eeb425707fa843c"
    redhat = "ami-0e306788ff2473ccb"
  }
  ami                    = each.value
  instance_type          = var.size
  
  vpc_security_group_ids = [aws_security_group.websg.id]
  key_name               = "Redhat_keypair"   # Replace with your actual key pair name

  tags = {
    Name = each.key
    env  = "prod"
  }
}
