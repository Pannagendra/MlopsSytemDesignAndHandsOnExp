################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_oidc_provider_arn" {
  description = "oidc_provider_arn"
  value       = module.eks.oidc_provider_arn
}

output "eks_managed_node_groups" {
  description = "eks_managed_node_groups"
  value       = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "eks_managed_node_groups_autoscaling_group_names"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}

output "cluster_service_cidr" {
  description = "cluster_service_cidr - The CIDR block where Kubernetes pod and service IP addresses are assigned from"
  value       = module.eks.cluster_service_cidr
}

output "cluster_primary_security_group_id" {
  description = "cluster_primary_security_group_id - Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  description = "node_security_group_id - ID of the node shared security group"
  value       = module.eks.node_security_group_id
}
