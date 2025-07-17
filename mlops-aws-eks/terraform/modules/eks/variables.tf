variable "env_name_suffix" {
  description = "MLOps platform environment name"
  type        = string
}

variable "kubernetes_version" {
  default     = "1.30"
  description = "kubernetes version"
  type        = string
}

variable "eks_cluster_name" {
  default     = "mlops"
  description = "name of the cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "principle_arn_cluster_access" {
  description = "Principle Cluster Access ARN"
  default     = "arn:aws:iam::acc_num:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_AdministratorAccess_b29155f1462ab8d5"
}
variable "iam_role_arn_cluster_role" {
  default     = "arn:aws:iam::acc_num:role/AWS-EKS-cluster-role"
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`"
  type        = string
}

variable "iam_role_arn_worker_role" {
  default     = "arn:aws:iam::acc_num:role/AWS-EKS-workerNode-role"
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`"
  type        = string
}

variable "aws_region" {
  description = "aws region"
  type        = string
}

#
# EKS configurations
#
variable "eks_config" {
  description = "EKS configuration settings"
  type = object({
    default_ng = object({
      instance_type = list(string)
      min_size      = number
      max_size      = number
      desired_size  = number
    })
    tags = object({
      app_owner = string
      team      = string
      workload  = string
    })
  })
}

#
# Teanant wise configurations
#
variable "tenant_config" {
  description = "Configuration settings for each tenant"
  type = map(object({
    ng_config = object({
      min_size      = number
      max_size      = number
      desired_size  = number
      instance_type = list(string)
      tags = object({
        app_owner = string
        team      = string
        workload  = string
      })
    })
  }))
}
