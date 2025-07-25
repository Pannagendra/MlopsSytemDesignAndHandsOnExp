provider "aws"{
    region = var.aws_region
    profile = var.sso_profile_name
}

provider "kubernetes"{
    host = module.eks.cluster_endpoint
    cluster_ca_certificate= base64decode(module.eks.cluster_certificate_authority_data)
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", "mlops-profile" ]
        command = "aws"
    }
}

provider "kubectl"{
    host = module.eks.cluster_endpoint
    cluster_ca_certificate= base64decode(module.eks.cluster_certificate_authority_data)
    load_config_file = false
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", "mlops-profile" ]
        command = "aws"
    }
}

provider "helm" {
    debug = true
    kubernetes{
            host = module.eks.cluster_endpoint
            cluster_ca_certificate= base64decode(module.eks.cluster_certificate_authority_data)
            exec {
                api_version = "client.authentication.k8s.io/v1beta1"
                args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", "mlops-profile" ]
                command = "aws"
                }
    }
}