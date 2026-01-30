module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = var.project_name
  cidr            = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.availability_zones

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.project_name}-cluster"
  kubernetes_version = "1.31"
  region             = var.aws_region

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  eks_managed_node_groups = {
    deafult = {
      instance_types = [var.node_instance_type]
      min_size       = 1
      max_size       = 1
      desired_size   = 1
    }

  }

  tags = var.tags
}
