# Terraform configuration

provider "aws" {
  region = "ap-southeast-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name           = "my-ec2-cluster"
  instance_count = 2

  ami                    = var.server_ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.web_server_sg.this_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  user_data = <<-EOF
              #!/bin/bash
              sudo su
              yum -y update
              yum -y install httpd
              echo "Hello, World" | tee /var/www/html/index.html
              systemctl start httpd
              EOF

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
