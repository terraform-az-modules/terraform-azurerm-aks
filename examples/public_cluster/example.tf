##-----------------------------------------------------------------------------
## Provider
##-----------------------------------------------------------------------------
provider "azurerm" {
  features {}
  subscription_id = "1ac2caa4-336e-4daa-b8f1-0fbabe2d4b11"
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

# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
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

  # node_pools = {
  #   testpool = {
  #     vm_size                       = "Standard_D2s_v5"
  #     os_type                       = "Linux"
  #     vnet_subnet_id                = module.subnet.subnet_ids.subnet1
  #     node_count                    = 1
  #     mode                          = "User"
  #     os_disk_type                  = null
  #     os_disk_size_gb               = null
  #     enable_auto_scaling           = null
  #     enable_host_encryption        = null
  #     eviction_policy               = null
  #     gpu_instance                  = null
  #     gpu_driver                    = null
  #     node_public_ip_prefix_id      = null
  #     os_sku                        = null
  #     priority                      = null
  #     temporary_name_for_rotation   = null
  #     min_count                     = null
  #     max_count                     = null
  #     max_pods                      = null
  #     enable_node_public_ip         = null
  #     orchestrator_version          = null
  #     node_taints                   = null
  #     host_group_id                 = null
  #     zones                         = null
  #     max_surge                     = null
  #     node_soak_duration_in_minutes = null
  #     drain_timeout_in_minutes      = null
  #     capacity_reservation_group_id = null
  #     workload_runtime              = null
  #     fips_enabled                  = null
  #     kubelet_disk_type             = null
  #     node_labels                   = null
  #     pod_subnet_id                 = null
  #     proximity_placement_group_id  = null
  #     scale_down_mode               = null
  #     snapshot_id                   = null
  #     spot_max_price                = null
  #     tags                          = null
  #     ultra_ssd_enabled             = null
  #   }
  # }
}
