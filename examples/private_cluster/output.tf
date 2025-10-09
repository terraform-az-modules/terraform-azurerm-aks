output "aks_id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = module.aks.aks_id
}

output "current_kubernetes_version" {
  description = "Current running Kubernetes version on the AKS cluster."
  value       = module.aks.current_kubernetes_version
}

output "fqdn" {
  description = "Public FQDN of the AKS cluster."
  value       = module.aks.fqdn
}

output "private_fqdn" {
  description = "Private FQDN when private link is enabled."
  value       = module.aks.private_fqdn
}

output "portal_fqdn" {
  description = "Azure Portal FQDN when private link is enabled."
  value       = module.aks.portal_fqdn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL associated with the AKS cluster."
  value       = module.aks.oidc_issuer_url
}

output "node_resource_group" {
  description = "Auto-generated resource group for AKS nodes."
  value       = module.aks.node_resource_group
}

output "node_resource_group_id" {
  description = "ID of the node resource group."
  value       = module.aks.node_resource_group_id
}

output "identity_principal_id" {
  description = "Principal ID of the AKS managed identity."
  value       = module.aks.identity_principal_id
}

output "identity_tenant_id" {
  description = "Tenant ID of the AKS managed identity."
  value       = module.aks.identity_tenant_id
}

output "kube_config_raw" {
  description = "Raw kubeconfig for user access."
  value       = module.aks.kube_config_raw
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "Raw kubeconfig for admin access (if local accounts enabled)."
  value       = module.aks.kube_admin_config_raw
  sensitive   = true
}

output "kube_config" {
  description = "Structured kube_config block (includes client credentials)."
  value       = module.aks.kube_config
  sensitive   = true
}

output "kube_admin_config" {
  description = "Structured kube_admin_config block (includes client credentials)."
  value       = module.aks.kube_admin_config
  sensitive   = true
}

output "network_profile" {
  description = "Network profile block of the AKS cluster."
  value       = module.aks.network_profile
}

output "lb_effective_outbound_ips" {
  description = "Effective outbound IPs from Standard Load Balancer profile."
  value       = module.aks.lb_effective_outbound_ips
}

output "natgw_effective_outbound_ips" {
  description = "Effective outbound IPs from NAT Gateway profile."
  value       = module.aks.natgw_effective_outbound_ips
}

output "aci_connector_identity_client_id" {
  description = "Client ID for user-assigned identity used by the ACI Connector."
  value       = module.aks.aci_connector_identity_client_id
}

output "aci_connector_identity_object_id" {
  description = "Object ID for user-assigned identity used by the ACI Connector."
  value       = module.aks.aci_connector_identity_object_id
}

output "aci_connector_identity_id" {
  description = "Resource ID for user-assigned identity used by the ACI Connector."
  value       = module.aks.aci_connector_identity_id
}

output "kubelet_identity_client_id" {
  description = "Client ID for user-assigned identity of kubelets."
  value       = module.aks.kubelet_identity_client_id
}

output "kubelet_identity_object_id" {
  description = "Object ID for user-assigned identity of kubelets."
  value       = module.aks.kubelet_identity_object_id
}

output "kubelet_identity_id" {
  description = "Resource ID for user-assigned identity of kubelets."
  value       = module.aks.kubelet_identity_id
}

output "ingress_appgw_effective_gateway_id" {
  description = "Application Gateway ID for AKS ingress controller."
  value       = module.aks.ingress_appgw_effective_gateway_id
}

output "ingress_appgw_identity_client_id" {
  description = "Client ID of managed identity for Application Gateway."
  value       = module.aks.ingress_appgw_identity_client_id
}

output "ingress_appgw_identity_object_id" {
  description = "Object ID of managed identity for Application Gateway."
  value       = module.aks.ingress_appgw_identity_object_id
}

output "ingress_appgw_identity_id" {
  description = "Resource ID of user-assigned identity for Application Gateway."
  value       = module.aks.ingress_appgw_identity_id
}

output "oms_agent_identity_client_id" {
  description = "Client ID of managed identity used by OMS Agents."
  value       = module.aks.oms_agent_identity_client_id
}

output "oms_agent_identity_object_id" {
  description = "Object ID of managed identity used by OMS Agents."
  value       = module.aks.oms_agent_identity_object_id
}

output "oms_agent_identity_id" {
  description = "Resource ID of user-assigned identity used by OMS Agents."
  value       = module.aks.oms_agent_identity_id
}

output "kv_secrets_provider_client_id" {
  description = "Client ID of managed identity used by Key Vault Secrets Provider."
  value       = module.aks.kv_secrets_provider_client_id
}

output "kv_secrets_provider_object_id" {
  description = "Object ID of managed identity used by Key Vault Secrets Provider."
  value       = module.aks.kv_secrets_provider_object_id
}

output "kv_secrets_provider_identity_id" {
  description = "Resource ID of user-assigned identity used by Key Vault Secrets Provider."
  value       = module.aks.kv_secrets_provider_identity_id
}

output "web_app_routing_identity_client_id" {
  description = "Client ID of managed identity for Web App Routing."
  value       = module.aks.web_app_routing_identity_client_id
}

output "web_app_routing_identity_object_id" {
  description = "Object ID of managed identity for Web App Routing."
  value       = module.aks.web_app_routing_identity_object_id
}

output "web_app_routing_identity_id" {
  description = "Resource ID of user-assigned identity used for Web App Routing."
  value       = module.aks.web_app_routing_identity_id
}

output "http_application_routing_zone_name" {
  description = "Zone name for HTTP Application Routing add-on, if enabled."
  value       = module.aks.http_application_routing_zone_name
}
