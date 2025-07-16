variable "env_name_suffix"{
    description = "Mlops platform name"
    type = string
}

variable "aws_region"{
    description = "aws region"
    type = string
    default = "asia pacific"
}
variable "sso_profile_name"{
    description = "sso for mlops-profile"
    default = "mlops-profile"
}

variable "mlops_tf_s3_bucket_name"{
    description = "s3 bucket name for storing tf state"
    default = "mlops-tf-state-01"
}

variable "mlops_dynamo_db_table"{
    description = "dynamo db table for state lock storage"
    default = "mlops-tf-state-table"
}

variable "vpc_id"{
    description = "vpc id"
    type = string
    default = "vpc-012345samplevpcid"
}
variable "private_subnets"{
    desciption = "subnet id without public ip"
    type = list(string)
}
variable "principle_arn_cluster_access"{
    desciption = "Principle cluster access"
    default = "arn:aws:iam::account_number:role/aws_role_with_admin_access_marketplacemetering_acces_marketplace_admin_access"
}

variable "eks_config"{
    description = "EKS  config settings"
    type = object({
        default_ng=object({
            instance_type=list(string)
            min_size = number
            max_size = number
            desired_size = number
        })
        tags = object({
            app_owner = string
            team = string
            workload = string
        })
    })
}

variable "rds_config"{
    description = "RDS db config settings"
    type = object({
        db_password = string
        tags = object({
            app_owner = string
            team = string
            workload = string
        })
    })
}

variable "ingress_ssl_config"{
    description = "ingress description and SSL config"
    type = object({
        subnets = string
        airflow = object({
            certificate_arn = string
            host = string
            webserver_base_url = string
        })
        mlflow = object({
            certificate_arn = string
            host = string
        })
    })
}

variable "tenant_config"{
    description = "config setting for each tenant"
    type = map(object({
        ng_config = object({
            min_size = number
            max_size = number
            desired_size = number
            instance_type = list(string)
            tags = object({
                app_owner = string
                team = string
                workload = string
            })
        })
        airflow = optional(object({
            webserver = object({
                replicas = number
                admin_password = string
                resources = object({
                    limits = object ({
                        cpu = string
                        memory = string
                    })
                    requests = object ({
                        cpu = string
                        memory = string
                    })
                })
            })
            scheduler = object({
                replicas = number
                resources = object({
                    limits = object ({
                        cpu = string
                        memory = string
                    })
                    requests = object ({
                        cpu = string
                        memory = string
                    })
                })
            })
            pgbouncer = object({
                replicas = number
                metricExporterSideCar = object({
                    resources = object({
                        limits = object ({
                        cpu = string
                        memory = string
                        })
                        requests = object ({
                        cpu = string
                        memory = string
                        })
                    }) 
                })
            })
            triggerer = object({
                replicas = number
            })
            dags = object({
                replicas = number
                resources =  object ({
                    limits = object({
                        cpu = string
                        memory = string
                    })
                    requests = object({
                        cpu = string
                        memory = string
                    })
                })
                git_sync = object({
                    username = string
                    password = string
                    email = string
                    git_repo = string
                    git_branch = string
                })
                image = object({
                    repository = string
                    tag = string
                })
            })
            tags = object({
                app_owner = string
                team = string
                workload = string
            })
        }))
        mlflow = optional(object({
            git_sync = object({
                username = string
                password = string
                email = string
            })
            image = object({
                repository = string
                tag = string
            })
            tracking = object({
                resources = object({
                    limits = object({
                        cpu = string
                        memory = string
                    })
                    requests = object({
                        cpu = string
                        memory = string
                    })
                })
                autoscaling = object ({
                    hpa = object({
                        tracking_autoscaling_hpa_minReplicas = string
                        tracking_autoscaling_hpa_maxReplicas = string
                        tracking_autoscaling_hpa_target_cpu = string
                        tracking_autoscaling_hpa_target_memory = string
                    })
                })
            })
            tags = object({
                app_owner = string
                team = string
                workload = string
            })
            db_config = object ({
                auth_db_username = string
                auth_db_password = string
            })
        }))
    }))
}