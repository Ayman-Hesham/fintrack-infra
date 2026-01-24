module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.project_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = var.enable_nat_gateway ? module.vpc.private_subnets : module.vpc.public_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    instance_types = var.node_instance_types

    subnet_ids = var.enable_nat_gateway ? module.vpc.private_subnets : module.vpc.public_subnets
  }

  eks_managed_node_groups = {
    main = {
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      instance_types = var.node_instance_types
      capacity_type  = var.use_spot_instances ? "SPOT" : "ON_DEMAND"

      enable_bootstrap_user_data = !var.enable_nat_gateway

      labels = {
        Environment = var.environment
        Role        = "worker"
      }

      tags = {
        Name = "${var.project_name}-node"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true

  enable_irsa = true
}
