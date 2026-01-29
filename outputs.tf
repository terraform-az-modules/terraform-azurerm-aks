##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "aks_id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = try(azurerm_kubernetes_cluster.main[0].id, null)
}

output "current_kubernetes_version" {
  description = "Current running Kubernetes version on the AKS cluster."
  value       = try(azurerm_kubernetes_cluster.main[0].current_kubernetes_version, null)
}

output "fqdn" {
  description = "Public FQDN of the AKS cluster."
  value       = try(azurerm_kubernetes_cluster.main[0].fqdn, null)
}

output "private_fqdn" {
  description = "Private FQDN when private link is enabled."
  value       = try(azurerm_kubernetes_cluster.main[0].private_fqdn, null)
}

output "portal_fqdn" {
  description = "Azure Portal FQDN when private link is enabled."
  value       = try(azurerm_kubernetes_cluster.main[0].portal_fqdn, null)
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL associated with the AKS cluster."
  value       = try(azurerm_kubernetes_cluster.main[0].oidc_issuer_url, null)
}

output "node_resource_group" {
  description = "Auto-generated resource group for AKS nodes."
  value       = try(azurerm_kubernetes_cluster.main[0].node_resource_group, null)
}

output "node_resource_group_id" {
  description = "ID of the node resource group."
  value       = try(azurerm_kubernetes_cluster.main[0].node_resource_group_id, null)
}

output "identity_principal_id" {
  description = "Principal ID of the AKS managed identity."
  value       = try(azurerm_kubernetes_cluster.main[0].identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "Tenant ID of the AKS managed identity."
  value       = try(azurerm_kubernetes_cluster.main[0].identity[0].tenant_id, null)
}

output "kube_config_raw" {
  description = "Raw kubeconfig for user access."
  value       = try(azurerm_kubernetes_cluster.main[0].kube_config_raw, null)
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "Raw kubeconfig for admin access (if local accounts enabled)."
  value       = try(azurerm_kubernetes_cluster.main[0].kube_admin_config_raw, null)
  sensitive   = true
}

output "kube_config" {
  description = "Structured kube_config block (includes client credentials)."
  value       = try(azurerm_kubernetes_cluster.main[0].kube_config[0], null)
  sensitive   = true
}

output "kube_admin_config" {
  description = "Structured kube_admin_config block (includes client credentials)."
  value       = try(azurerm_kubernetes_cluster.main[0].kube_admin_config[0], null)
  sensitive   = true
}

output "network_profile" {
  description = "Network profile block of the AKS cluster."
  value       = try(azurerm_kubernetes_cluster.main[0].network_profile[0], null)
}

output "lb_effective_outbound_ips" {
  description = "Effective outbound IPs from Standard Load Balancer profile."
  value       = try(azurerm_kubernetes_cluster.main[0].network_profile[0].load_balancer_profile[0].effective_outbound_ips, [])
}

output "natgw_effective_outbound_ips" {
  description = "Effective outbound IPs from NAT Gateway profile."
  value       = try(azurerm_kubernetes_cluster.main[0].network_profile[0].nat_gateway_profile[0].effective_outbound_ips, [])
}

output "aci_connector_identity_client_id" {
  description = "Client ID for user-assigned identity used by the ACI Connector."
  value       = try(azurerm_kubernetes_cluster.main[0].aci_connector_linux[0].connector_identity[0].client_id, null)
}

output "aci_connector_identity_object_id" {
  description = "Object ID for user-assigned identity used by the ACI Connector."
  value       = try(azurerm_kubernetes_cluster.main[0].aci_connector_linux[0].connector_identity[0].object_id, null)
}

output "aci_connector_identity_id" {
  description = "Resource ID for user-assigned identity used by the ACI Connector."
  value       = try(azurerm_kubernetes_cluster.main[0].aci_connector_linux[0].connector_identity[0].user_assigned_identity_id, null)
}

output "kubelet_identity_client_id" {
  description = "Client ID for user-assigned identity of kubelets."
  value       = try(azurerm_kubernetes_cluster.main[0].kubelet_identity[0].client_id, null)
}

output "kubelet_identity_object_id" {
  description = "Object ID for user-assigned identity of kubelets."
  value       = try(azurerm_kubernetes_cluster.main[0].kubelet_identity[0].object_id, null)
}

output "kubelet_identity_id" {
  description = "Resource ID for user-assigned identity of kubelets."
  value       = try(azurerm_kubernetes_cluster.main[0].kubelet_identity[0].user_assigned_identity_id, null)
}

output "ingress_appgw_effective_gateway_id" {
  description = "Application Gateway ID for AKS ingress controller."
  value       = try(azurerm_kubernetes_cluster.main[0].ingress_application_gateway[0].effective_gateway_id, null)
}

output "ingress_appgw_identity_client_id" {
  description = "Client ID of managed identity for Application Gateway."
  value       = try(azurerm_kubernetes_cluster.main[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].client_id, null)
}

output "ingress_appgw_identity_object_id" {
  description = "Object ID of managed identity for Application Gateway."
  value       = try(azurerm_kubernetes_cluster.main[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id, null)
}

output "ingress_appgw_identity_id" {
  description = "Resource ID of user-assigned identity for Application Gateway."
  value       = try(azurerm_kubernetes_cluster.main[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].user_assigned_identity_id, null)
}

output "oms_agent_identity_client_id" {
  description = "Client ID of managed identity used by OMS Agents."
  value       = try(azurerm_kubernetes_cluster.main[0].oms_agent[0].oms_agent_identity[0].client_id, null)
}

output "oms_agent_identity_object_id" {
  description = "Object ID of managed identity used by OMS Agents."
  value       = try(azurerm_kubernetes_cluster.main[0].oms_agent[0].oms_agent_identity[0].object_id, null)
}

output "oms_agent_identity_id" {
  description = "Resource ID of user-assigned identity used by OMS Agents."
  value       = try(azurerm_kubernetes_cluster.main[0].oms_agent[0].oms_agent_identity[0].user_assigned_identity_id, null)
}

output "kv_secrets_provider_client_id" {
  description = "Client ID of managed identity used by Key Vault Secrets Provider."
  value       = try(azurerm_kubernetes_cluster.main[0].key_vault_secrets_provider[0].secret_identity[0].client_id, null)
}

output "kv_secrets_provider_object_id" {
  description = "Object ID of managed identity used by Key Vault Secrets Provider."
  value       = try(azurerm_kubernetes_cluster.main[0].key_vault_secrets_provider[0].secret_identity[0].object_id, null)
}

output "kv_secrets_provider_identity_id" {
  description = "Resource ID of user-assigned identity used by Key Vault Secrets Provider."
  value       = try(azurerm_kubernetes_cluster.main[0].key_vault_secrets_provider[0].secret_identity[0].user_assigned_identity_id, null)
}

output "web_app_routing_identity_client_id" {
  description = "Client ID of managed identity for Web App Routing."
  value       = try(azurerm_kubernetes_cluster.main[0].web_app_routing[0].web_app_routing_identity[0].client_id, null)
}

output "web_app_routing_identity_object_id" {
  description = "Object ID of managed identity for Web App Routing."
  value       = try(azurerm_kubernetes_cluster.main[0].web_app_routing[0].web_app_routing_identity[0].object_id, null)
}

output "web_app_routing_identity_id" {
  description = "Resource ID of user-assigned identity used for Web App Routing."
  value       = try(azurerm_kubernetes_cluster.main[0].web_app_routing[0].web_app_routing_identity[0].user_assigned_identity_id, null)
}

output "http_application_routing_zone_name" {
  description = "Zone name for HTTP Application Routing add-on, if enabled."
  value       = try(azurerm_kubernetes_cluster.main[0].http_application_routing_zone_name, null)
}

output "kubernetes_flux_configuration_id" {
  description = "Kubernetes Flux Configuration ID"
  value       = try(azurerm_kubernetes_flux_configuration.main[0].id, null)
}

output "kubernetes_fleet_update_strategy_id" {
  description = "Kubernetes Fleet Update Strategy ID"
  value       = try(azurerm_kubernetes_fleet_update_strategy.main[0].id, null)
}

output "kubernetes_fleet_update_run_id" {
  description = "Kubernetes Fleet Update Run ID"
  value       = try(azurerm_kubernetes_fleet_update_run.main[0].id, null)
}

output "kubernetes_fleet_member_id" {
  description = "Kubernetes Fleet Member ID"
  value       = try(azurerm_kubernetes_fleet_member.main[0].id, null)
}

output "kubernetes_fleet_manager_id" {
  description = "Kubernetes Fleet Manager ID"
  value       = try(azurerm_kubernetes_fleet_manager.main[0].id, null)
}

output "kubernetes_cluster_extension_id" {
  description = "Kubernetes Cluster Extension ID"
  value       = try(azurerm_kubernetes_cluster_extension.main[0].id, null)
}

output "kubernetes_cluster_extension_current_version" {
  description = "Current version of Kubernetes Cluster Extension"
  value       = try(azurerm_kubernetes_cluster_extension.main[0].current_version, null)
}

output "kubernetes_cluster_extension_identity_type" {
  description = "Identity type of Kubernetes Cluster Extension"
  value       = try(azurerm_kubernetes_cluster_extension.main[0].aks_assigned_identity[0].type, null)
}

output "kubernetes_cluster_extension_principal_id" {
  description = "Principal ID of Kubernetes Cluster Extension managed identity"
  value       = try(azurerm_kubernetes_cluster_extension.main[0].aks_assigned_identity[0].principal_id, null)
}

output "kubernetes_cluster_extension_tenant_id" {
  description = "Tenant ID of Kubernetes Cluster Extension managed identity"
  value       = try(azurerm_kubernetes_cluster_extension.main[0].aks_assigned_identity[0].tenant_id, null)
}
