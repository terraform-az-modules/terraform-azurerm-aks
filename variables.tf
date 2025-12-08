##-----------------------------------------------------------------------------
## Naming convention
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Override default naming convention"
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = <<EOT
Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.

- If true, the keyword is prepended: "vnet-core-dev".
- If false, the keyword is appended: "core-dev-vnet".

This helps maintain naming consistency based on organizational preferences.
EOT
}

##-----------------------------------------------------------------------------
## Labels
##-----------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = null
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "location" {
  type        = string
  default     = null
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "environment" {
  type        = string
  default     = null
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy, eg 'terraform-az-modules'."
}

variable "label_order" {
  type        = list(string)
  default     = ["name", "environment", "location"]
  description = "The order of labels used to construct resource names or tags."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-aks"
  description = "Terraform current module repo"

  validation {
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Variable to pass extra tags."
}

##-----------------------------------------------------------------------------
## Global Variables
##-----------------------------------------------------------------------------
variable "enable" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "A container that holds related resources for an Azure solution"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.31"
  description = "Version of Kubernetes to deploy"
}

variable "node_resource_group" {
  type        = string
  default     = null
  description = "Name of the resource group in which to put AKS nodes. If null default to MC_<AKS RG Name>"
}

variable "edge_zone" {
  type        = string
  default     = null
  description = "Edge Zone for the AKS cluster."
}

##-----------------------------------------------------------------------------
## Cluster Configuration
##-----------------------------------------------------------------------------
variable "aks_sku_tier" {
  type        = string
  default     = "Standard"
  description = "AKS SKU tier. Possible values are Free or Paid"
}

variable "automatic_channel_upgrade" {
  type        = string
  default     = null
  description = "Auto-upgrade channel: `patch`, `rapid`, `node-image`, `stable`."
}

variable "local_account_disabled" {
  type        = bool
  default     = false
  description = "Disable local account?"
}

##-----------------------------------------------------------------------------
## Network Configuration
##-----------------------------------------------------------------------------
variable "network_plugin" {
  type        = string
  default     = "azure"
  description = "Network plugin for networking."
}

variable "network_policy" {
  type        = string
  default     = "azure"
  description = "Network policy to be used with Azure CNI (`calico` or `azure`)."
}

variable "network_plugin_mode" {
  type        = string
  default     = null
  description = "Network plugin mode (e.g., `Overlay`)."
}

variable "network_data_plane" {
  type        = string
  default     = null
  description = "eBPF data plane (e.g., `cilium`)."
}

variable "service_cidr" {
  type        = string
  default     = "10.2.0.0/16"
  description = "CIDR used by kubernetes services."
}

variable "net_profile_pod_cidr" {
  type        = string
  default     = null
  description = "Pod CIDR (kubenet only)."
}

variable "outbound_type" {
  type        = string
  default     = "loadBalancer"
  description = "Outbound routing method: `loadBalancer` or `userDefinedRouting`."
}

variable "vnet_id" {
  type        = string
  default     = null
  description = "VNet id that AKS MSI should be Network Contributor on (private cluster)."
}

variable "outbound_nat_enabled" {
  type        = bool
  default     = true
  description = "Windows nodes outbound NAT enabled."
}

##-----------------------------------------------------------------------------
## Private Cluster Configuration
##-----------------------------------------------------------------------------
variable "private_cluster_enabled" {
  type        = bool
  default     = false
  description = "Configure AKS as a Private Cluster"
}

variable "private_dns_zone_type" {
  type        = string
  default     = "Custom"
  description = <<EOD
Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)
- "Custom": Bring your own Private DNS Zone and pass its id via `private_dns_zone_id`.
- "System": AKS manages the zone in the Node Resource Group.
- "None": Bring your own DNS server/resolution.
EOD
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Id of the private DNS Zone when <private_dns_zone_type> is Custom"
}

##-----------------------------------------------------------------------------
## API Server Access Configuration
##-----------------------------------------------------------------------------
variable "api_server_access_profile" {
  type = object({
    authorized_ip_ranges     = optional(list(string))
    vnet_integration_enabled = optional(bool)
    subnet_id                = optional(string)
  })
  default     = null
  description = "Control public/private API server exposure"
}

##-----------------------------------------------------------------------------
## Load Balancer Configuration
##-----------------------------------------------------------------------------
variable "load_balancer_sku" {
  type        = string
  default     = "standard"
  description = "Load Balancer SKU: `basic` or `standard`."
  validation {
    condition     = contains(["basic", "standard"], var.load_balancer_sku)
    error_message = "Possible values are `basic` and `standard`"
  }
}

variable "load_balancer_profile_enabled" {
  type        = bool
  default     = false
  description = "Enable a load_balancer_profile block (requires `standard` SKU)."
  nullable    = false
}

variable "load_balancer_profile_idle_timeout_in_minutes" {
  type        = number
  default     = 30
  description = "Outbound flow idle timeout in minutes for the cluster load balancer (4–120)."
}

variable "load_balancer_profile_managed_outbound_ip_count" {
  type        = number
  default     = null
  description = "Count of managed outbound IPs (1–100)."
}

variable "load_balancer_profile_managed_outbound_ipv6_count" {
  type        = number
  default     = null
  description = "Count of managed outbound IPv6 IPs (requires dual-stack)."
}

variable "load_balancer_profile_outbound_ip_address_ids" {
  type        = set(string)
  default     = null
  description = "Public IP IDs for outbound communication."
}

variable "load_balancer_profile_outbound_ip_prefix_ids" {
  type        = set(string)
  default     = null
  description = "Public IP Prefix IDs for outbound communication."
}

variable "load_balancer_profile_outbound_ports_allocated" {
  type        = number
  default     = 0
  description = "SNAT ports per VM (0–64000)."
}

##-----------------------------------------------------------------------------
## Default Node Pool Configuration
##-----------------------------------------------------------------------------
variable "default_node_pool_config" {
  description = "Configuration for the default system node pool"
  type = object({
    name                         = optional(string, null)
    node_count                   = optional(number, null)
    vm_size                      = optional(string, null)
    enable_auto_scaling          = optional(bool, false)
    enable_host_encryption       = optional(bool, null)
    min_count                    = optional(number, null)
    max_count                    = optional(number, null)
    type                         = optional(string, null)
    vnet_subnet_id               = string
    max_pods                     = optional(number, null)
    os_disk_type                 = optional(string, null)
    os_disk_size_gb              = optional(number, null)
    os_sku                       = optional(string, null)
    orchestrator_version         = optional(string, null)
    enable_node_public_ip        = optional(bool, null)
    zones                        = optional(list(string), null)
    node_labels                  = optional(map(string), null)
    only_critical_addons_enabled = optional(bool, null)
    fips_enabled                 = optional(bool, null)
    proximity_placement_group_id = optional(string, null)
    scale_down_mode              = optional(string, null)
    snapshot_id                  = optional(string, null)
    temporary_name_for_rotation  = optional(string, null)
    ultra_ssd_enabled            = optional(bool, null)
    pod_subnet_id                = optional(string, null)
    tags                         = optional(map(string), null)
  })
}

variable "agents_pool_max_surge" {
  type        = string
  default     = "10%"
  description = "The maximum number or percentage of nodes which will be added to the Default Node Pool size during an upgrade."
}

variable "agents_pool_node_soak_duration_in_minutes" {
  type        = number
  default     = 0
  description = "(Optional) The amount of time in minutes to wait after draining a node and before reimaging and moving on to next node. Defaults to 0."
}

variable "agents_pool_drain_timeout_in_minutes" {
  type        = number
  default     = null
  description = "(Optional) The amount of time in minutes to wait on eviction of pods and graceful termination per node. This eviction wait time honors waiting on pod disruption budgets. If this time is exceeded, the upgrade fails. Unsetting this after configuring it will force a new resource to be created."
}

##-----------------------------------------------------------------------------
## Additional Node Pools Configuration
##-----------------------------------------------------------------------------
variable "node_pools" {
  description = "Map of additional node pools"
  type = map(object({
    vm_size                       = optional(string, null)
    os_type                       = optional(string, null)
    os_disk_type                  = optional(string, null)
    os_disk_size_gb               = optional(number, null)
    vnet_subnet_id                = string
    enable_auto_scaling           = optional(bool, false)
    enable_host_encryption        = optional(bool, null)
    eviction_policy               = optional(string, null)
    gpu_instance                  = optional(string)
    os_sku                        = optional(string, null)
    priority                      = optional(string, null)
    node_count                    = optional(number, null)
    min_count                     = optional(number, null)
    max_count                     = optional(number, null)
    max_pods                      = optional(number, 50)
    enable_node_public_ip         = optional(bool, null)
    mode                          = optional(string, null)
    orchestrator_version          = optional(string, null)
    node_taints                   = optional(list(string), null)
    host_group_id                 = optional(string, null)
    zones                         = optional(list(string), null)
    node_soak_duration_in_minutes = optional(number, null)
    drain_timeout_in_minutes      = optional(number, null)
    capacity_reservation_group_id = optional(string, null)
    workload_runtime              = optional(string, null)
    fips_enabled                  = optional(bool, null)
    kubelet_disk_type             = optional(string, null)
    node_labels                   = optional(map(string), null)
    pod_subnet_id                 = optional(string, null)
    proximity_placement_group_id  = optional(string, null)
    temporary_name_for_rotation   = optional(string, null)
    scale_down_mode               = optional(string, null)
    snapshot_id                   = optional(string, null)
    spot_max_price                = optional(number, null)
    tags                          = optional(map(string), null)
    ultra_ssd_enabled             = optional(bool, null)
  }))
  default = {}
}

variable "node_public_ip_tags" {
  type        = map(string)
  default     = {}
  description = "Tags for node public IPs."
}

##-----------------------------------------------------------------------------
## Node Pool Advanced Configuration
##-----------------------------------------------------------------------------
variable "kubelet_config" {
  type = object({
    allowed_unsafe_sysctls    = optional(list(string))
    container_log_max_line    = optional(number)
    container_log_max_size_mb = optional(string)
    cpu_cfs_quota_enabled     = optional(bool)
    cpu_cfs_quota_period      = optional(string)
    cpu_manager_policy        = optional(string)
    image_gc_high_threshold   = optional(number)
    image_gc_low_threshold    = optional(number)
    pod_max_pid               = optional(number)
    topology_manager_policy   = optional(string)
  })
  default     = null
  description = "Kubelet configuration options."
}

variable "agents_pool_kubelet_configs" {
  type = list(object({
    cpu_manager_policy        = optional(string)
    cpu_cfs_quota_enabled     = optional(bool, true)
    cpu_cfs_quota_period      = optional(string)
    image_gc_high_threshold   = optional(number)
    image_gc_low_threshold    = optional(number)
    topology_manager_policy   = optional(string)
    allowed_unsafe_sysctls    = optional(set(string))
    container_log_max_size_mb = optional(number)
    container_log_max_line    = optional(number)
    pod_max_pid               = optional(number)
  }))
  default     = []
  description = "Per-pool kubelet configs (advanced)."
}

variable "agents_pool_linux_os_configs" {
  type = list(object({
    sysctl_configs = optional(list(object({
      fs_aio_max_nr                      = optional(number)
      fs_file_max                        = optional(number)
      fs_inotify_max_user_watches        = optional(number)
      fs_nr_open                         = optional(number)
      kernel_threads_max                 = optional(number)
      net_core_netdev_max_backlog        = optional(number)
      net_core_optmem_max                = optional(number)
      net_core_rmem_default              = optional(number)
      net_core_rmem_max                  = optional(number)
      net_core_somaxconn                 = optional(number)
      net_core_wmem_default              = optional(number)
      net_core_wmem_max                  = optional(number)
      net_ipv4_ip_local_port_range_min   = optional(number)
      net_ipv4_ip_local_port_range_max   = optional(number)
      net_ipv4_neigh_default_gc_thresh1  = optional(number)
      net_ipv4_neigh_default_gc_thresh2  = optional(number)
      net_ipv4_neigh_default_gc_thresh3  = optional(number)
      net_ipv4_tcp_fin_timeout           = optional(number)
      net_ipv4_tcp_keepalive_intvl       = optional(number)
      net_ipv4_tcp_keepalive_probes      = optional(number)
      net_ipv4_tcp_keepalive_time        = optional(number)
      net_ipv4_tcp_max_syn_backlog       = optional(number)
      net_ipv4_tcp_max_tw_buckets        = optional(number)
      net_ipv4_tcp_tw_reuse              = optional(bool)
      net_netfilter_nf_conntrack_buckets = optional(number)
      net_netfilter_nf_conntrack_max     = optional(number)
      vm_max_map_count                   = optional(number)
      vm_swappiness                      = optional(number)
      vm_vfs_cache_pressure              = optional(number)
    })), [])
    transparent_huge_page_enabled = optional(string)
    transparent_huge_page_defrag  = optional(string)
    swap_file_size_mb             = optional(number)
  }))
  default     = []
  description = <<-EOT
  list(object({
    sysctl_configs = optional(list(object({
      fs_aio_max_nr                      = (Optional) The sysctl setting fs.aio-max-nr. Must be between `65536` and `6553500`. Changing this forces a new resource to be created.
      fs_file_max                        = (Optional) The sysctl setting fs.file-max. Must be between `8192` and `12000500`. Changing this forces a new resource to be created.
      fs_inotify_max_user_watches        = (Optional) The sysctl setting fs.inotify.max_user_watches. Must be between `781250` and `2097152`. Changing this forces a new resource to be created.
      fs_nr_open                         = (Optional) The sysctl setting fs.nr_open. Must be between `8192` and `20000500`. Changing this forces a new resource to be created.
      kernel_threads_max                 = (Optional) The sysctl setting kernel.threads-max. Must be between `20` and `513785`. Changing this forces a new resource to be created.
      net_core_netdev_max_backlog        = (Optional) The sysctl setting net.core.netdev_max_backlog. Must be between `1000` and `3240000`. Changing this forces a new resource to be created.
      net_core_optmem_max                = (Optional) The sysctl setting net.core.optmem_max. Must be between `20480` and `4194304`. Changing this forces a new resource to be created.
      net_core_rmem_default              = (Optional) The sysctl setting net.core.rmem_default. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.
      net_core_rmem_max                  = (Optional) The sysctl setting net.core.rmem_max. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.
      net_core_somaxconn                 = (Optional) The sysctl setting net.core.somaxconn. Must be between `4096` and `3240000`. Changing this forces a new resource to be created.
      net_core_wmem_default              = (Optional) The sysctl setting net.core.wmem_default. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.
      net_core_wmem_max                  = (Optional) The sysctl setting net.core.wmem_max. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.
      net_ipv4_ip_local_port_range_min   = (Optional) The sysctl setting net.ipv4.ip_local_port_range max value. Must be between `1024` and `60999`. Changing this forces a new resource to be created.
      net_ipv4_ip_local_port_range_max   = (Optional) The sysctl setting net.ipv4.ip_local_port_range min value. Must be between `1024` and `60999`. Changing this forces a new resource to be created.
      net_ipv4_neigh_default_gc_thresh1  = (Optional) The sysctl setting net.ipv4.neigh.default.gc_thresh1. Must be between `128` and `80000`. Changing this forces a new resource to be created.
      net_ipv4_neigh_default_gc_thresh2  = (Optional) The sysctl setting net.ipv4.neigh.default.gc_thresh2. Must be between `512` and `90000`. Changing this forces a new resource to be created.
      net_ipv4_neigh_default_gc_thresh3  = (Optional) The sysctl setting net.ipv4.neigh.default.gc_thresh3. Must be between `1024` and `100000`. Changing this forces a new resource to be created.
      net_ipv4_tcp_fin_timeout           = (Optional) The sysctl setting net.ipv4.tcp_fin_timeout. Must be between `5` and `120`. Changing this forces a new resource to be created.
      net_ipv4_tcp_keepalive_intvl       = (Optional) The sysctl setting net.ipv4.tcp_keepalive_intvl. Must be between `10` and `75`. Changing this forces a new resource to be created.
      net_ipv4_tcp_keepalive_probes      = (Optional) The sysctl setting net.ipv4.tcp_keepalive_probes. Must be between `1` and `15`. Changing this forces a new resource to be created.
      net_ipv4_tcp_keepalive_time        = (Optional) The sysctl setting net.ipv4.tcp_keepalive_time. Must be between `30` and `432000`. Changing this forces a new resource to be created.
      net_ipv4_tcp_max_syn_backlog       = (Optional) The sysctl setting net.ipv4.tcp_max_syn_backlog. Must be between `128` and `3240000`. Changing this forces a new resource to be created.
      net_ipv4_tcp_max_tw_buckets        = (Optional) The sysctl setting net.ipv4.tcp_max_tw_buckets. Must be between `8000` and `1440000`. Changing this forces a new resource to be created.
      net_ipv4_tcp_tw_reuse              = (Optional) The sysctl setting net.ipv4.tcp_tw_reuse. Changing this forces a new resource to be created.
      net_netfilter_nf_conntrack_buckets = (Optional) The sysctl setting net.netfilter.nf_conntrack_buckets. Must be between `65536` and `147456`. Changing this forces a new resource to be created.
      net_netfilter_nf_conntrack_max     = (Optional) The sysctl setting net.netfilter.nf_conntrack_max. Must be between `131072` and `1048576`. Changing this forces a new resource to be created.
      vm_max_map_count                   = (Optional) The sysctl setting vm.max_map_count. Must be between `65530` and `262144`. Changing this forces a new resource to be created.
      vm_swappiness                      = (Optional) The sysctl setting vm.swappiness. Must be between `0` and `100`. Changing this forces a new resource to be created.
      vm_vfs_cache_pressure              = (Optional) The sysctl setting vm.vfs_cache_pressure. Must be between `0` and `100`. Changing this forces a new resource to be created.
    })), [])
    transparent_huge_page_enabled = (Optional) Specifies the Transparent Huge Page enabled configuration. Possible values are `always`, `madvise` and `never`. Changing this forces a new resource to be created.
    transparent_huge_page_defrag  = (Optional) specifies the defrag configuration for Transparent Huge Page. Possible values are `always`, `defer`, `defer+madvise`, `madvise` and `never`. Changing this forces a new resource to be created.
    swap_file_size_mb             = (Optional) Specifies the size of the swap file on each node in MB. Changing this forces a new resource to be created.
  }))
EOT
  nullable    = false
}

##-----------------------------------------------------------------------------
## Auto Scaler Configuration
##-----------------------------------------------------------------------------
variable "auto_scaler_profile_enabled" {
  type        = bool
  default     = false
  description = "Enable configuring the cluster autoscaler profile"
  nullable    = false
}

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups      = bool
    empty_bulk_delete_max            = number
    expander                         = string
    max_graceful_termination_sec     = string
    max_node_provisioning_time       = string
    max_unready_nodes                = number
    max_unready_percentage           = number
    new_pod_scale_up_delay           = string
    scale_down_delay_after_add       = string
    scale_down_delay_after_delete    = string
    scale_down_delay_after_failure   = string
    scale_down_unneeded              = string
    scale_down_unready               = string
    scale_down_utilization_threshold = string
    scan_interval                    = string
    skip_nodes_with_local_storage    = bool
    skip_nodes_with_system_pods      = bool
  })
  default = {
    balance_similar_node_groups      = false
    empty_bulk_delete_max            = 10
    expander                         = "random"
    max_graceful_termination_sec     = "600"
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = null
    scale_down_delay_after_failure   = "3m"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = "0.5"
    scan_interval                    = "10s"
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }
  description = "Cluster autoscaler profile configuration"
}

variable "workload_autoscaler_profile" {
  type = object({
    keda_enabled                    = optional(bool, false)
    vertical_pod_autoscaler_enabled = optional(bool, false)
  })
  default     = null
  description = "Workload autoscaler profile (KEDA/VPA)."
}

##-----------------------------------------------------------------------------
## Linux Profile Configuration
##-----------------------------------------------------------------------------
variable "linux_profile" {
  description = "Username and ssh key for accessing AKS Linux nodes with ssh."
  type = object({
    username = string,
    ssh_key  = string
  })
  default = null
}

##-----------------------------------------------------------------------------
## Windows Profile Configuration
##-----------------------------------------------------------------------------
variable "windows_profile" {
  type = object({
    admin_username = string
    admin_password = optional(string)
    license        = optional(string)
    gmsa = optional(object({
      dns_server  = string
      root_domain = string
    }))
  })
  default     = null
  description = "Windows profile configuration"
}

##-----------------------------------------------------------------------------
## Identity Configuration
##-----------------------------------------------------------------------------
variable "kubelet_identity" {
  type = object({
    client_id                 = optional(string)
    object_id                 = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default     = null
  description = "User-assigned identity for Kubelets (optional)."
}

variable "client_id" {
  type        = string
  default     = ""
  description = "Service Principal Client ID"
  nullable    = false
}

variable "client_secret" {
  type        = string
  default     = ""
  description = "Service Principal Client Secret"
  nullable    = false
}

##-----------------------------------------------------------------------------
## RBAC and Access Control
##-----------------------------------------------------------------------------
variable "role_based_access_control_enabled" {
  type        = bool
  default     = true
  description = "Enable Role-Based Access Control (RBAC) for the AKS cluster"
}

variable "role_based_access_control" {
  type = list(object({
    managed            = bool
    tenant_id          = optional(string)
    azure_rbac_enabled = bool
  }))
  default     = null
  description = "RBAC configuration block specifying managed AAD integration, tenant ID, and Azure RBAC enablement"
}

variable "admin_group_id" {
  type        = list(string)
  default     = null
  description = "List of Azure AD group object IDs that will have admin access to the AKS cluster"
}

variable "admin_objects_ids" {
  type        = list(string)
  default     = null
  description = "List of Azure AD object IDs (users or service principals) that will have admin access to the AKS cluster"
}

variable "user_aks_roles" {
  description = "Map of role definitions to their respective admin group IDs"
  type = map(object({
    role_definition = string
    principal_ids   = list(string)
  }))
  default = null
}

variable "aks_user_auth_role" {
  type        = any
  default     = []
  description = "Group/User role-based access to AKS"
}

##-----------------------------------------------------------------------------
## ACR Integration
##-----------------------------------------------------------------------------
variable "acr_enabled" {
  type        = bool
  default     = false
  description = "Enable ACR access for AKS"
}

variable "acr_id" {
  type        = string
  default     = null
  description = "ACR resource ID to grant access to AKS"
}

##-----------------------------------------------------------------------------
## Add-ons Configuration
##-----------------------------------------------------------------------------
variable "azure_policy_enabled" {
  type        = bool
  default     = true
  description = "Enable Azure Policy Addon."
}

variable "microsoft_defender_enabled" {
  type        = bool
  default     = false
  description = "Enable Microsoft Defender add-on."
}

variable "oms_agent_enabled" {
  type        = bool
  default     = false
  description = "Enable Log Analytics (OMS agent) add-on."
}

variable "aci_connector_linux_enabled" {
  type        = bool
  default     = false
  description = "Enable Virtual Node pool"
}

variable "aci_connector_linux_subnet_name" {
  type        = string
  default     = null
  description = "aci_connector_linux subnet name"
}

##-----------------------------------------------------------------------------
## Service Mesh Configuration
##-----------------------------------------------------------------------------
variable "service_mesh_profile" {
  type = object({
    mode                             = string
    internal_ingress_gateway_enabled = optional(bool, true)
    external_ingress_gateway_enabled = optional(bool, true)
  })
  default     = null
  description = "Istio service mesh configuration."
}

variable "web_app_routing" {
  type = object({
    dns_zone_ids = list(string)
  })
  default     = null
  description = "Web App Routing configuration (DNS Zone IDs)."
}

##-----------------------------------------------------------------------------
## Storage Configuration
##-----------------------------------------------------------------------------
variable "storage_profile_enabled" {
  type        = bool
  default     = false
  description = "Enable storage profile"
  nullable    = false
}

variable "storage_profile" {
  type = object({
    enabled                     = bool
    blob_driver_enabled         = bool
    disk_driver_enabled         = bool
    disk_driver_version         = string
    file_driver_enabled         = bool
    snapshot_controller_enabled = bool
  })
  default = {
    enabled                     = false
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    disk_driver_version         = "v1"
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }
  description = "Storage profile configuration"
}

##-----------------------------------------------------------------------------
## Monitoring and Logging
##-----------------------------------------------------------------------------
variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of Log Analytics workspace"
}

variable "msi_auth_for_monitoring_enabled" {
  type        = bool
  default     = false
  description = "Enable managed identity auth for monitoring?"
}

variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "AzureDiagnostics or Dedicated (LA tables)."
}

variable "diagnostic_setting_enable" {
  type        = bool
  description = "Enable or disable diagnostic settings for this resource"
  default     = false
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Destination Storage Account ID for Diagnostic Settings."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Destination Event Hub name for Diagnostic Settings."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Event Hub auth rule ID for Diagnostic Settings."
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Diagnostic Metric enabled?"
}

variable "pip_logs" {
  type = object({
    enabled        = bool
    category       = optional(list(string))
    category_group = optional(list(string))
  })
  description = "Configuration for Public IP diagnostic log settings. Specify log categories or category groups to collect"
  default = {
    enabled        = true
    category_group = ["AllLogs"]
  }
}

variable "kv_logs" {
  type = object({
    enabled        = bool
    category       = optional(list(string))
    category_group = optional(list(string))
  })
  description = "Configuration for Key Vault diagnostic log settings. Specify log categories or category groups to collect"
  default = {
    enabled        = true
    category_group = ["AllLogs"]
  }
}

##-----------------------------------------------------------------------------
## Image Cleaner Configuration
##-----------------------------------------------------------------------------
variable "image_cleaner_enabled" {
  type        = bool
  default     = false
  description = "Enable Image Cleaner."
}

variable "image_cleaner_interval_hours" {
  type        = number
  default     = 48
  description = "Interval (hours) for image cleanup."
}

##-----------------------------------------------------------------------------
## HTTP Proxy Configuration
##-----------------------------------------------------------------------------
variable "enable_http_proxy" {
  type        = bool
  default     = false
  description = "Enable HTTP proxy configuration."
}

variable "http_proxy_config" {
  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(list(string))
    trusted_ca  = optional(string)
  })
  default     = null
  description = "HTTP Proxy configuration"
}

##-----------------------------------------------------------------------------
## Maintenance Windows
##-----------------------------------------------------------------------------
variable "maintenance_window_node_os" {
  type = object({
    day_of_month = optional(number)
    day_of_week  = optional(string)
    duration     = number
    frequency    = string
    interval     = number
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(set(object({
      end   = string
      start = string
    })))
  })
  default     = null
  description = "Maintenance window for node OS."
}

variable "maintenance_window_auto_upgrade" {
  type = object({
    frequency    = string
    interval     = number
    duration     = number
    day_of_week  = optional(string)
    day_of_month = optional(number)
    week_index   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    start_date   = optional(string)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })))
  })
  default     = null
  description = "Maintenance window for auto-upgrades."
}

##-----------------------------------------------------------------------------
## Confidential Computing
##-----------------------------------------------------------------------------
variable "confidential_computing" {
  type = object({
    sgx_quote_helper_enabled = bool
  })
  default     = null
  description = "Enable Confidential Computing (SGX)."
}

##-----------------------------------------------------------------------------
## Key Vault Integration
##-----------------------------------------------------------------------------
variable "key_vault_id" {
  type        = string
  default     = null
  description = "Key Vault (or Key URL) used for Disk Encryption Set, etc."
}

variable "key_vault_secrets_provider_enabled" {
  type        = bool
  default     = false
  description = "Enable Secrets Store CSI Driver (AKV provider)."
  nullable    = false
}

variable "secret_rotation_enabled" {
  type        = bool
  default     = false
  description = "Enable secret rotation (requires AKV CSI)."
  nullable    = false
}

variable "secret_rotation_interval" {
  type        = string
  default     = "2m"
  description = "Secret rotation poll interval (used when rotation enabled)."
  nullable    = false
}

variable "rotation_policy_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to enable rotation policy"
}

variable "rotation_policy" {
  type = map(object({
    time_before_expiry   = string
    expire_after         = string
    notify_before_expiry = string
  }))
  default = {
    example_rotation_policy = {
      time_before_expiry   = "P30D"
      expire_after         = "P90D"
      notify_before_expiry = "P29D"
    }
  }
  description = "Key Vault certificate rotation policy configuration with ISO 8601 duration format (e.g., P30D for 30 days)"
}

variable "expiration_date" {
  type        = string
  default     = "2026-09-17T23:59:59Z"
  description = "Expiration UTC datetime (Y-m-d'T'H:M:S'Z')"
}

##-----------------------------------------------------------------------------
## Customer-Managed Keys (CMK) Configuration
##-----------------------------------------------------------------------------
variable "cmk_enabled" {
  type        = bool
  default     = true
  description = "Flag to control resource creation related to CMK encryption."
}

variable "cmk_key_type" {
  type        = string
  default     = "RSA-HSM"
  description = "Key type (e.g., RSA, EC)."
}

variable "cmk_key_size" {
  type        = number
  default     = 2048
  description = "Key size for RSA (2048/3072/4096)."
}

variable "cmk_key_ops" {
  type        = set(string)
  default     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  description = "Allowed key operations."
}

variable "cmk_des_key_permissions" {
  type        = list(string)
  default     = ["Get", "WrapKey", "UnwrapKey"]
  description = "Key permissions for the Disk Encryption Set identity."
}

variable "cmk_des_certificate_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Certificate permissions for the Disk Encryption Set identity."
}

variable "cmk_aks_key_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Key permissions for the AKS managed identity."
}

variable "cmk_aks_certificate_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Certificate permissions for the AKS managed identity."
}

variable "cmk_aks_secret_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Secret permissions for the AKS managed identity."
}

variable "cmk_kubelet_key_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Key permissions for the kubelet identity."
}

variable "cmk_kubelet_certificate_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Certificate permissions for the kubelet identity."
}

variable "cmk_kubelet_secret_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Secret permissions for the kubelet identity."
}

##-----------------------------------------------------------------------------
## KMS Configuration
##-----------------------------------------------------------------------------
variable "kms_enabled" {
  type        = bool
  default     = false
  description = "Enable Azure KeyVault Key Management Service."
}

variable "kms_key_vault_key_id" {
  type        = string
  default     = null
  description = "Identifier of Azure Key Vault key (required if KMS enabled)."
}

variable "kms_key_vault_network_access" {
  type        = string
  default     = "Public"
  description = "Key Vault network access: `Private` or `Public`."
  validation {
    condition     = contains(["Private", "Public"], var.kms_key_vault_network_access)
    error_message = "Possible values are `Private` and `Public`"
  }
}