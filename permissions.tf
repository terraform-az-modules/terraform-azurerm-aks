resource "azurerm_role_assignment" "aks_entraid" {
  count                = var.enable && var.role_based_access_control != null && try(var.role_based_access_control[0].azure_rbac_enabled, false) == true ? length(var.admin_group_id) : 0
  scope                = azurerm_kubernetes_cluster.aks[0].id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.admin_group_id[count.index]
}

resource "azurerm_role_assignment" "aks_entraid_non_admin" {
  for_each             = var.enable && var.user_aks_roles != null && var.role_based_access_control != null && try(var.role_based_access_control[0].azure_rbac_enabled, false) == true ? { for idx, val in local.user_aks_roles_flat : idx => val } : {}
  scope                = azurerm_kubernetes_cluster.aks[0].id
  role_definition_name = each.value.role_definition
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "aks_system_identity" {
  count                = var.enable && var.cmk_enabled ? 1 : 0
  principal_id         = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id : azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = azurerm_disk_encryption_set.main[0].id
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "aks_acr_access_principal_id" {
  count                = var.enable && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "aks_acr_access_object_id" {
  count                = var.enable && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "aks_user_assigned" {
  count                = var.enable ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks[0].node_resource_group)
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "aks_uai_private_dns_zone_contributor" {
  count                = var.enable && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_uai_vnet_network_contributor" {
  count                = var.enable && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "key_vault_secrets_provider" {
  count                = var.enable && var.key_vault_secrets_provider_enabled ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_kubernetes_cluster.aks[0].key_vault_secrets_provider[0].secret_identity[0].object_id
}

resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each             = toset(var.enable && var.cmk_enabled ? var.admin_objects_ids : [])
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "azurerm_disk_encryption_set_key_vault_access" {
  count                = var.enable && var.cmk_enabled ? 1 : 0
  principal_id         = azurerm_disk_encryption_set.main[0].identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

# resource "azurerm_role_assignment" "appgw_role" {
#   count                = var.enable && var.gateway_enabled ? 1 : 0
#   principal_id         = data.azurerm_user_assigned_identity.appgw_uami[0].principal_id
#   scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks[0].node_resource_group)
#   role_definition_name = "Contributor"
# }

# resource "azurerm_role_assignment" "agic_appgw_contributor" {
#   count                = var.enable && var.gateway_enabled ? 1 : 0
#   scope                = var.gateway_id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_kubernetes_cluster.aks[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
#   depends_on           = [azurerm_kubernetes_cluster.aks]
# }

# resource "azurerm_role_assignment" "agic_rg_reader" {
#   count                = var.enable && var.gateway_enabled ? 1 : 0
#   scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name)
#   role_definition_name = "Reader"
#   principal_id         = azurerm_kubernetes_cluster.aks[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
#   depends_on           = [azurerm_kubernetes_cluster.aks]
# }

# resource "azurerm_role_assignment" "appgw_identity_operator" {
#   count                = var.enable && var.gateway_enabled ? 1 : 0
#   scope                = data.azurerm_user_assigned_identity.appgw_uami[0].id
#   role_definition_name = "Managed Identity Operator"
#   principal_id         = azurerm_kubernetes_cluster.aks[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
# }

# resource "azurerm_role_assignment" "appgw_subnet_join" {
#   count                = var.enable && var.gateway_enabled ? 1 : 0
#   scope                = data.azurerm_application_gateway.appgw[0].gateway_ip_configuration[0].subnet_id
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_kubernetes_cluster.aks[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
# }

# resource "azurerm_role_assignment" "example" {
#   for_each             = var.enable && var.aks_user_auth_role != null ? { for k in var.aks_user_auth_role : k.principal_id => k } : {}
#   scope                = each.value.scope
#   role_definition_name = each.value.role_definition_name
#   principal_id         = each.value.principal_id
# }

resource "azurerm_user_assigned_identity" "aks_user_assigned_identity" {
  count               = var.enable && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  name                = format("%s-aks-mid", module.labels.id)
  resource_group_name = var.resource_group_name
  location            = var.location
}