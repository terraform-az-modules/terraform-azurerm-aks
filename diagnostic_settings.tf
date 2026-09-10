##-----------------------------------------------------------------------------
## Diagnostic Settings
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "diag" {
  depends_on                     = [azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.main]
  count                          = var.enable && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-diag-log-%s", local.name) : format("%s-aks-diag-log", local.name)
  target_resource_id             = azurerm_kubernetes_cluster.main[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  dynamic "enabled_log" {
    for_each = var.aks_logs.enabled ? var.aks_logs.category != null ? var.aks_logs.category : var.aks_logs.category_group : []
    content {
      category       = var.aks_logs.category != null ? enabled_log.value : null
      category_group = var.aks_logs.category == null ? enabled_log.value : null
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

##-----------------------------------------------------------------------------
## Public IP diagnostic setting
## target_resource_id is sorted deterministically so the selection never
## flips between plans even if the node RG happens to contain more than one
## public IP (e.g. multiple managed outbound IPs).
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "pip_diag" {
  depends_on                     = [data.azurerm_resources.aks_pip, azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.main]
  count                          = var.enable && var.diagnostic_setting_enable && length(try(data.azurerm_resources.aks_pip[0].resources, [])) > 0 ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-pip-diag-log-%s", local.name) : format("%s-aks-pip-diag-log", local.name)
  target_resource_id             = sort(data.azurerm_resources.aks_pip[0].resources[*].id)[0]
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  dynamic "enabled_log" {
    for_each = var.pip_logs.enabled ? var.pip_logs.category != null ? var.pip_logs.category : var.pip_logs.category_group : []
    content {
      category       = var.pip_logs.category != null ? enabled_log.value : null
      category_group = var.pip_logs.category == null ? enabled_log.value : null
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

##-----------------------------------------------------------------------------
## NSG diagnostic setting
## count guards against an empty result (e.g. BYO-subnet clusters where AKS
## does not manage its own NSG in the node RG) so apply never fails on an
## index-out-of-range error.
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "nsg_diag" {
  depends_on                     = [data.azurerm_resources.aks_nsg, azurerm_kubernetes_cluster.main]
  count                          = var.enable && var.diagnostic_setting_enable && var.nsg_diagnostic_setting_enable && length(try(data.azurerm_resources.aks_nsg[0].resources, [])) > 0 ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-nsg-diag-log-%s", local.name) : format("%s-aks-nsg-diag-log", local.name)
  target_resource_id             = sort(data.azurerm_resources.aks_nsg[0].resources[*].id)[0]
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_log" {
    for_each = var.nsg_logs
    content {
      category_group = enabled_log.value.category_group
      category       = enabled_log.value.category
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

##-----------------------------------------------------------------------------
## NIC diagnostic setting
## Sorted deterministically since multiple node pools can produce multiple
## NICs in the node RG.
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "nic_diag" {
  depends_on                     = [data.azurerm_resources.aks_nic, azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.main]
  count                          = var.enable && var.diagnostic_setting_enable && var.private_cluster_enabled == true && length(try(data.azurerm_resources.aks_nic[0].resources, [])) > 0 ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-nic-diag-log-%s", local.name) : format("%s-aks-nic-diag-log", local.name)
  target_resource_id             = sort(data.azurerm_resources.aks_nic[0].resources[*].id)[0]
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}
