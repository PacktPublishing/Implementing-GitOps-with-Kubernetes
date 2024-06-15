terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5"
    }
  }
}

provider "aws" {
  region = "eu-central-1"

}


# ECR creation
resource "aws_ecr_repository" "ecr" {
  name                 = "weather-app"
  image_tag_mutability = "MUTABLE"
}

# VPC and subnets

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "eks-cluster-vpc"
  cidr = "10.0.0.0/16"

  # At least two AZs in the region are required for EKS.
  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  enable_nat_gateway     = true
  single_nat_gateway     = true

  enable_dns_hostnames = true


  public_subnet_tags = {
    "kubernetes.io/cluster/eksgitopscluster" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/eksgitopscluster" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "eksgitopscluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {    
    instance_types = ["t3.small"]
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  create_node_security_group = true
}


# IAM role to allow EKS nodes to pull images from ECR
resource "aws_iam_policy" "ecr_pull" {
  name        = "ecr-pull-policy"
  path        = "/"
  description = "IAM policy for EKS to pull images from ECR"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ecr:GetAuthorizationToken",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
        ],
        Effect   = "Allow",
        Resource = aws_ecr_repository.ecr.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_pull_attach" {
  role       = module.eks.cluster_iam_role_name
  policy_arn = aws_iam_policy.ecr_pull.arn
}