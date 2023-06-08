terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}

provider "aws" {

}

module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = "10.0.0.0/16"
  dellsubnet1 = "10.0.2.0/24"
  dellsubnet2 = "10.0.1.0/24"
  dellsubnet3 = "10.0.3.0/24"
  dellsubnet4 = "10.0.4.0/24"
  dellsubnet5 = "10.0.5.0/24"
  dellsubnet6 = "10.0.6.0/24"

}

module "elb" {
  source              = "./modules/elb"
  security_groups_web = module.vpc.security_groups_web
  publicsubnet1       = module.vpc.publicsubnet1
  publicsubnet2       = module.vpc.publicsubnet2
  vpc_id              = module.vpc.vpc_id
}


module "autoscaling" {
  source            = "./modules/autoscaling"
  security_groups   = module.vpc.security_groups_web
  desired_capacity  = 1
  max_size          = 2
  min_size          = 1
  publicsubnet1     = module.vpc.publicsubnet1
  publicsubnet2     = module.vpc.publicsubnet2
  target_group_arns = module.elb.target_group_arns
}

module "rds" {
  source                 = "./modules/rds"
  engine                 = "mysql"
  identifier             = "rajeshrdsinstance"
  username               = "khemraj"
  password               = "khemraj123456"
  instance_type          = "db.t2.micro"
  allocated_storage      = 10
  vpc_security_group_ids = module.vpc.vpc_security_group_ids
  db_subnet_group_name = module.vpc.aws_db_subnet_group
}