data "azurerm_resources" "aks_nic" {
  depends_on = [azurerm_kubernetes_cluster.main]
  count      = var.enable && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  type       = "Microsoft.Network/networkInterfaces"
}

data "azurerm_resources" "aks_nsg" {
  depends_on = [azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.node_pools]
  count      = var.enable && var.diagnostic_setting_enable ? 1 : 0
  type       = "Microsoft.Network/networkSecurityGroups"
}

data "azurerm_resources" "aks_pip" {
  depends_on = [azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.node_pools]
  count      = var.enable && var.diagnostic_setting_enable ? 1 : 0
  type       = "Microsoft.Network/publicIPAddresses"
}