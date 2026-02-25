module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = "online-boutique-cluster"
  cluster_version = "1.31"
  cluster_endpoint_public_access = true # Це вирішить проблему з timeout

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    main = {
      min_size     = 3
      max_size     = 5
      desired_size = 4
      instance_types = ["t3.small"]
    }
  }
}