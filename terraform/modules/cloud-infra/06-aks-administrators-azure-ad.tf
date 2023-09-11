# Administrator group for this cluster
resource "azuread_group" "aks_administrators" {
    display_name = "${var.resource_group_name_cluster_prefix}-${var.environment}-cluster-administrators"
    description = "Azure AKS administrators for the environment: ${var.environment}" 
    security_enabled = true
}