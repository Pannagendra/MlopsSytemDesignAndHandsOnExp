module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "mlops-eks-cluster"
  cluster_version = "1.29"
  subnet_ids      = [aws_subnet.public_a.id, aws_subnet.private_a.id]
  vpc_id          = aws_vpc.main.id

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Name = "mlops-eks"
  }
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_kubeconfig" {
  value = module.eks.kubeconfig
}
