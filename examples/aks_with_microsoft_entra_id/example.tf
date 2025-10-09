##-----------------------------------------------------------------------------
## Provider
##-----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

##-----------------------------------------------------------------------------
## Resource Group
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azure"
  version     = "1.0.0"
  name        = "core"
  environment = "qa"
  label_order = ["environment", "name", "location"]
  location    = "canadacentral"
}

##-----------------------------------------------------------------------------
## Vnet
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azure"
  version             = "1.0.0"
  name                = "core"
  environment         = "qa"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

module "subnet" {
  source               = "terraform-az-modules/subnet/azure"
  version              = "1.0.0"
  environment          = "dev"
  label_order          = ["name", "environment", "location"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name            = "subnet1"
      subnet_prefixes = ["10.0.1.0/24"]
    }
  ]
}

# ------------------------------------------------------------------------------
# Log Analytics
# ------------------------------------------------------------------------------
module "log-analytics" {
  source                      = "terraform-az-modules/log-analytics/azure"
  version                     = "1.0.0"
  name                        = "core"
  environment                 = "dev"
  label_order                 = ["name", "environment", "location"]
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  log_analytics_workspace_id  = module.log-analytics.workspace_id
}


module "vault" {
  source                        = "terraform-az-modules/key-vault/azure"
  version                       = "1.0.0"
  name                          = "core"
  custom_name                   = "bulbulka9121"
  environment                   = "dev"
  label_order                   = ["name", "environment", "location"]
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  subnet_id                     = module.subnet.subnet_ids.subnet1
  public_network_access_enabled = true
  enable_private_endpoint       = false
  sku_name                      = "premium"
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
}

module "aks" {
  source                     = "../.."
  name                       = "core"
  environment                = "dev"
  resource_group_name        = module.resource_group.resource_group_name
  location                   = module.resource_group.resource_group_location
  key_vault_id               = module.vault.id
  admin_objects_ids          = [data.azurerm_client_config.current_client_config.object_id]
  microsoft_defender_enabled = false
  diagnostic_setting_enable  = false
  private_cluster_enabled    = false
  vnet_id                    = module.vnet.vnet_id
  kubernetes_version         = "1.30"
  default_node_pool_config = {
    name                          = "agentpool"
    node_count                    = 1
    vm_size                       = "Standard_D2_v3"
    os_type                       = "Linux"
    enable_auto_scaling           = false
    enable_host_encryption        = false
    min_count                     = null
    max_count                     = null
    vnet_subnet_id                = module.subnet.subnet_ids.subnet1
    type                          = "VirtualMachineScaleSets"
    node_taints                   = null
    max_pods                      = 30
    os_disk_type                  = "Managed"
    os_disk_size_gb               = 128
    host_group_id                 = null
    orchestrator_version          = null
    enable_node_public_ip         = false
    mode                          = "System"
    node_soak_duration_in_minutes = null
    max_surge                     = null
    drain_timeout_in_minutes      = null
    zones                         = []
    node_labels                   = {}
    only_critical_addons_enabled  = true
  }
  ## Microsoft entra_id integration
  local_account_disabled = true
  admin_group_id         = ["***ed"]

  role_based_access_control = [{
    managed   = true
    tenant_id = "b****f7bdd" ## To be mentioned when azure aks with microsoft entra_id with kubernetes rbac is enabled (or azure_rbac_enabled = true, in variable role_based_access_control)
    #admin_group_object_ids = ["*****-b3da-46c5-b672-fbc9bf0b****"] ## To be mentioned when azure aks with microsoft entra_id with kubernetes rbac is enabled (or azure_rbac_enabled = true, in variable role_based_access_control)
    azure_rbac_enabled = true
  }]

  aks_user_auth_role = [{
    scope                = "/subscriptions/0**5e1cabc60c/resourceGroups/public-app-test-resource-group/providers/Microsoft.ContainerService/managedClusters/app1-test-aks1/namespaces/test"
    role_definition_name = "Azure Kubernetes Service RBAC Admin"
    principal_id         = "***-**-***-**-***" # user or group object id 
  }]

  log_analytics_workspace_id = module.log-analytics.workspace_id # when diagnostic_setting_enable = true && oms_agent_enabled = true
}
