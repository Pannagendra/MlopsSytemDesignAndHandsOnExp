module "network"{
    source = "./modules/network"
    private_subnets = var. private_subnets
}

module "rds"{
    source = "./module/rds"
    sso_profile_name = var.sso_profile_name
    vpc_id = var.vpc_id
    private_subnet_ids = var.private_subnet_ids
    aws_region = var.aws_region
    env_name_suffix = var.env_name_suffix
    rds_config=var.rds_config
}
module "eks"{
    source = "./module/eks"
    env_name_suffix = var.env_name_suffix
    vpc_id = var.vpc_id
    private_subnet_ids = var.private_subnet_ids
    aws_region = var.aws_region
    tenant_config = var.tenant_config
    eks_config = var.eks_config
}

resource "time_sleep" "wait_300_seconds"{
    depends_on = [module.rds , module.eks]
    create_duration = "300s"
}

module "ingress_controller"{
    depends_on = [module.rds, module.eks , time_sleep.wait_300_seconds]
    source = "./ingress_controller"
    sso_profile_name = var.sso_profile_name
    vpc_id = var.vpc_id
    aws_region = var.aws_region
    env_name_suffix = var.env_name_suffix
    cluster_endpoint = module.eks.cluster_endpoint
    cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
    cluster_name = module.eks.cluster_name
    ingress_ssl_config = var.ingress_ssl_config
}

module "apache-airflow"{
    for_each = {
        for k,v in var.tenant_config : k => v
        if try(v.airflow != null, false)
    }
    depends_on  = [module.rds, module.eks, time_sleep.wait_300_seconds, module.ingress_controller]
    source = "./apache-airflow"
    cluster_endpoint = module.eks.cluster_endpoint
    cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
    cluster_name = module.eks.cluster_name
    db_host = module.rds.rds_hostname
    db_user = module.rds.rds_username
    db_pass = module.rds.rds_passwrd
    aws_region = var.aws_region
    sso_profile_name = var.sso_profile_name
    env_name_suffix = var.env_name_suffix
    eks_oidc_provider = module.eks.eks_oidc_provider_arn
    tenant_id = each.key
    airflow = each.value.airflow
    ingress_ssl_config = var.ingress_ssl_config
}

module "mlflow-org"{
    for_each = {
        for k, v in var.tenant_config : k => v
        if try(v.mlflow != null,false)
    }
    depends_on = [module.rds, module.eks, time_sleep.wait_300_seconds,ingress_controller]
    source = "./mlflow-org"
    cluster_endpoint = module.eks.cluster_endpoint
    cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
    cluster_name = module.eks.cluster_name
    db_host = module.rds.rds_hostname
    db_user = module.rds.rds_username
    db_pass = module.rds.rds_passwrd
    aws_region = var.aws_region
    sso_profile_name = var.sso_profile_name
    env_name_suffix = var.env_name_suffix
    eks_oidc_provider = module.eks.eks_oidc_provider_arn
    tenant_id = each.key
    mlflow = each.value.mlflow
    ingress_ssl_config = var.ingress_ssl_config
}