output "cluster_endpoint"{
    description = "Endpoint for eks API cluster"
    value = module.eks.cluster_endpoint
}
output "cluster_name"{
    desciption = "Name of the eks cluster"
    value = var.eks.cluster_name
}