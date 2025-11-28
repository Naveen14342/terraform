provider "aws" {
  region = var.giant
}

backup "s3" {
  bucket         = "my-terraform-state-bucket"
  key            = "prod/terraform.tfstate" 
  region         = "ap-south-1"
  encrypt        = true
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
  ami                    = var.image
  instance_type          = var.size
  vpc_security_group_ids = [aws_security_group.websg.id]
  key_name               = "Redhat_keypair"   # Replace with your actual key pair name

  tags = {
    Name = "ubuntuserver"
    env  = "prod"
  }
}
