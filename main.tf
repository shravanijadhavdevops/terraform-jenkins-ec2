
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "jenkins_ec2" {
  ami           = "ami-04394a3a96907e9ec"
  instance_type = "t3.micro"

  tags = {
    Name        = "Terraform-Jenkins-EC2"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

output "instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.jenkins_ec2.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.jenkins_ec2.public_ip
}
