module "eks" {
  source = "terraform-aws-modules/eks/aws"
  # version                        = "20.17.2"
  version                        = "~> 20.0"
  cluster_name                   = "${var.eks_cluster_name}_${var.env_name_suffix}"
  create_iam_role                = false
  iam_role_arn                   = var.iam_role_arn_cluster_role
  cluster_version                = var.kubernetes_version
  cluster_endpoint_public_access = true
  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnet_ids
  # Not sure about Control Plane Subnets, for now setting it to var.private_subnets
  control_plane_subnet_ids = var.private_subnet_ids
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    amazon-cloudwatch-observability = {
      most_recent = true
    }
    aws-efs-csi-driver = {
      most_recent = true
    }
    aws-mountpoint-s3-csi-driver = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    create_iam_role = false
    iam_role_arn    = var.iam_role_arn_worker_role
    instance_types  = var.eks_config.default_ng.instance_type
    capacity_type   = "ON_DEMAND"
    # disk_size    = 50 # Disk Size in GiB
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 100
          volume_type           = "gp3"
          iops                  = 3000 # General Purpose SSD (gp3) - IOPS	3,000 IOPS free and $0.005/provisioned IOPS-month over 3,000
          throughput            = 125  # General Purpose SSD (gp3) - Throughput	125 MB/s free and $0.040/provisioned MB/s-month over 125
          encrypted             = true
          delete_on_termination = true
        }
      }
    }
  }

  eks_managed_node_groups = {
    "mlops-ng-${var.env_name_suffix}" = {
      min_size     = var.eks_config.default_ng.min_size
      max_size     = var.eks_config.default_ng.max_size
      desired_size = var.eks_config.default_ng.desired_size
    }
  }

  # When enabling authentication_mode = "API_AND_CONFIG_MAP", EKS will automatically create an access entry for the IAM role(s) used by managed node group(s) and Fargate profile(s).
  # authentication_mode = "API_AND_CONFIG_MAP"

  # Bootstrap Cluster Creator Admin Permissions
  # bootstrap_cluster_creator_admin_permissions = true

  # Cluster access entry
  # To add the current caller identity as an administrator
  # enable_cluster_creator_admin_permissions = true

  cluster_security_group_additional_rules = {
    ingress_ec2_tcp = {
      description = "Access EKS from EC2 instance."
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Environment = "${var.env_name_suffix}"
    Terraform   = "true"
    AppOwner    = "${var.eks_config.tags.app_owner}"
    Team        = "${var.eks_config.tags.team}"
    Workload    = "${var.eks_config.tags.workload}"
  }
}

resource "aws_iam_role" "cluster-autoscaler-role" {
  name = "cluster-autoscaler-role-${var.env_name_suffix}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${module.eks.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity"
      }
    ]
  })
}

# Policies for IAM role
resource "aws_iam_policy" "cluster-autoscaler-policy" {
  name = "cluster-autoscaler-policy-${var.env_name_suffix}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Attach Custom Policy to the Role
resource "aws_iam_role_policy_attachment" "cluster-autoscaler-policy-attachment" {
  role       = aws_iam_role.cluster-autoscaler-role.name
  policy_arn = aws_iam_policy.cluster-autoscaler-policy.arn
  depends_on = [aws_iam_policy.cluster-autoscaler-policy]
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.37.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster-autoscaler-role.arn
  }

}

#
# eks nodegroup for each tenant
#
module "eks_managed_node_group" {
  for_each             = var.tenant_config
  source               = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  name                 = "mlops-ng-${var.env_name_suffix}-${each.key}"
  cluster_name         = module.eks.cluster_name
  create_iam_role      = false
  iam_role_arn         = var.iam_role_arn_worker_role
  cluster_service_cidr = module.eks.cluster_service_cidr
  subnet_ids           = var.private_subnet_ids
  min_size     = each.value.ng_config.min_size
  max_size     = each.value.ng_config.max_size
  desired_size = each.value.ng_config.desired_size

  instance_types = each.value.ng_config.instance_type
  capacity_type  = "ON_DEMAND"

  # disk_size    = 50 # Disk Size in GiB
  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 200
        volume_type           = "gp3"
        iops                  = 3000 # General Purpose SSD (gp3) - IOPS	3,000 IOPS free and $0.005/provisioned IOPS-month over 3,000
        throughput            = 125  # General Purpose SSD (gp3) - Throughput	125 MB/s free and $0.040/provisioned MB/s-month over 125
        encrypted             = true
        delete_on_termination = true
      }
    }
  }

  labels = {
    tenant = each.key
  }

  taints = {
    tenant = {
      key    = "tenant"
      value  = each.key
      effect = "NO_SCHEDULE"
    }
  }

  tags = {
    Environment = "${var.env_name_suffix}"
    Terraform   = "true"
    AppOwner    = each.value.ng_config.tags.app_owner
    Team        = each.value.ng_config.tags.team
    Workload    = each.value.ng_config.tags.workload
  }
}
