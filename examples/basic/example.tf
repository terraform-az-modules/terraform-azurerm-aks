##-----------------------------------------------------------------------------
## Provider
##-----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Resource Group
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "aks-basic"
  environment = "dev"
  location    = "centralus"
  label_order = ["name", "environment"]
}

##-----------------------------------------------------------------------------
## Virtual Network
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "aks-basic"
  environment         = "dev"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Subnet
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
  environment          = "dev"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name            = "aks-subnet"
      subnet_prefixes = ["10.0.1.0/24"]
    }
  ]
}

##-----------------------------------------------------------------------------
## AKS Cluster (Basic - Public)
##-----------------------------------------------------------------------------
module "aks" {
  source                  = "../../"
  name                    = "aks-basic"
  environment             = "dev"
  resource_group_name     = module.resource_group.resource_group_name
  location                = module.resource_group.resource_group_location
  private_cluster_enabled = false
  private_dns_zone_type   = "None"
  vnet_id                 = module.vnet.vnet_id
  default_node_pool_config = {
    vnet_subnet_id  = module.subnet.subnet_ids.aks-subnet
    os_disk_type    = "Managed"
    os_disk_size_gb = 30
  }
  microsoft_defender_enabled = false
  diagnostic_setting_enable  = false
}
