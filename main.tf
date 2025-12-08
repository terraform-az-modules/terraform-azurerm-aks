##-----------------------------------------------------------------------------
# Standard Tagging Module – Applies standard tags to all resources for traceability
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/tags/azurerm"
  version         = "1.0.2"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

##-----------------------------------------------------------------------------
## AKS Cluster
##-----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  count                             = var.enable ? 1 : 0
  name                              = var.resource_position_prefix ? format("aks-%s", local.name) : format("%s-aks", local.name)
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = replace(module.labels.id, "/[\\W_]/", "-")
  kubernetes_version                = var.kubernetes_version
  automatic_upgrade_channel         = var.automatic_channel_upgrade
  sku_tier                          = var.aks_sku_tier
  node_resource_group               = var.node_resource_group == null ? format("%s-aks-node-rg", local.name) : var.node_resource_group
  disk_encryption_set_id            = var.key_vault_id != null ? azurerm_disk_encryption_set.main[0].id : null
  private_cluster_enabled           = var.private_cluster_enabled
  private_dns_zone_id               = var.private_cluster_enabled ? var.private_dns_zone_id : null
  azure_policy_enabled              = var.azure_policy_enabled
  edge_zone                         = var.edge_zone
  image_cleaner_enabled             = var.image_cleaner_enabled
  image_cleaner_interval_hours      = var.image_cleaner_interval_hours
  role_based_access_control_enabled = var.role_based_access_control_enabled
  local_account_disabled            = var.local_account_disabled
  dynamic "default_node_pool" {
    for_each = var.default_node_pool_config.enable_auto_scaling == false ? [var.default_node_pool_config] : []
    content {
      name                         = default_node_pool.value.name
      node_count                   = default_node_pool.value.node_count
      vm_size                      = default_node_pool.value.vm_size
      auto_scaling_enabled         = default_node_pool.value.enable_auto_scaling
      host_encryption_enabled      = default_node_pool.value.enable_host_encryption
      max_count                    = default_node_pool.value.max_count
      min_count                    = default_node_pool.value.min_count
      max_pods                     = default_node_pool.value.max_pods
      node_labels                  = default_node_pool.value.node_labels
      node_public_ip_enabled       = default_node_pool.value.enable_node_public_ip
      only_critical_addons_enabled = default_node_pool.value.only_critical_addons_enabled
      orchestrator_version         = default_node_pool.value.orchestrator_version
      os_disk_size_gb              = default_node_pool.value.os_disk_size_gb
      os_disk_type                 = default_node_pool.value.os_disk_type
      os_sku                       = default_node_pool.value.os_sku
      proximity_placement_group_id = default_node_pool.value.proximity_placement_group_id
      type                         = default_node_pool.value.type
      vnet_subnet_id               = default_node_pool.value.vnet_subnet_id
      zones                        = default_node_pool.value.zones
      fips_enabled                 = default_node_pool.value.fips_enabled
      scale_down_mode              = default_node_pool.value.scale_down_mode
      snapshot_id                  = default_node_pool.value.snapshot_id
      temporary_name_for_rotation  = default_node_pool.value.temporary_name_for_rotation
      ultra_ssd_enabled            = default_node_pool.value.ultra_ssd_enabled
      pod_subnet_id                = default_node_pool.value.pod_subnet_id
      tags                         = merge(module.labels.tags, default_node_pool.value.tags)
      node_network_profile {
        node_public_ip_tags = var.node_public_ip_tags
      }
      dynamic "kubelet_config" {
        for_each = var.agents_pool_kubelet_configs
        content {
          allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
          container_log_max_line    = kubelet_config.value.container_log_max_line
          container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
          cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
          cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
          cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
          image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
          image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
          pod_max_pid               = kubelet_config.value.pod_max_pid
          topology_manager_policy   = kubelet_config.value.topology_manager_policy
        }
      }
      dynamic "upgrade_settings" {
        for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]
        content {
          max_surge                     = var.agents_pool_max_surge
          drain_timeout_in_minutes      = var.agents_pool_drain_timeout_in_minutes
          node_soak_duration_in_minutes = var.agents_pool_node_soak_duration_in_minutes
        }
      }
      dynamic "linux_os_config" {
        for_each = var.agents_pool_linux_os_configs
        content {
          swap_file_size_mb            = linux_os_config.value.swap_file_size_mb
          transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag
          transparent_huge_page        = linux_os_config.value.transparent_huge_page
          dynamic "sysctl_config" {
            for_each = linux_os_config.value.sysctl_configs == null ? [] : linux_os_config.value.sysctl_configs
            content {
              fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
              fs_file_max                        = sysctl_config.value.fs_file_max
              fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
              fs_nr_open                         = sysctl_config.value.fs_nr_open
              kernel_threads_max                 = sysctl_config.value.kernel_threads_max
              net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
              net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
              net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
              net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
              net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
              net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
              net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
              net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
              net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
              net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
              net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
              net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
              net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
              net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
              net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
              net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
              net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
              net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
              net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
              net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
              net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
              vm_max_map_count                   = sysctl_config.value.vm_max_map_count
              vm_swappiness                      = sysctl_config.value.vm_swappiness
              vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
            }
          }
        }
      }
    }
  }
  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux_enabled ? ["aci_connector_linux"] : []
    content {
      subnet_name = var.aci_connector_linux_subnet_name
    }
  }
  dynamic "key_management_service" {
    for_each = var.kms_enabled ? ["key_management_service"] : []
    content {
      key_vault_key_id         = var.kms_key_vault_key_id
      key_vault_network_access = var.kms_key_vault_network_access
    }
  }
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? ["key_vault_secrets_provider"] : []
    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }
  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity == null ? [] : [var.kubelet_identity]
    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }
  dynamic "http_proxy_config" {
    for_each = var.enable_http_proxy && var.http_proxy_config != null ? [var.http_proxy_config] : []
    content {
      http_proxy  = http_proxy_config.value.http_proxy
      https_proxy = http_proxy_config.value.https_proxy
      no_proxy    = http_proxy_config.value.no_proxy
      trusted_ca  = try(http_proxy_config.value.trusted_ca, null)
    }
  }
  dynamic "confidential_computing" {
    for_each = var.confidential_computing == null ? [] : [var.confidential_computing]
    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
    }
  }
  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null ? [var.api_server_access_profile] : []
    content {
      authorized_ip_ranges     = api_server_access_profile.value.authorized_ip_ranges
      vnet_integration_enabled = api_server_access_profile.value.vnet_integration_enabled
      subnet_id                = api_server_access_profile.value.subnet_id
    }
  }
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile_enabled ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = auto_scaler_profile.value.balance_similar_node_groups
      empty_bulk_delete_max            = auto_scaler_profile.value.empty_bulk_delete_max
      expander                         = auto_scaler_profile.value.expander
      max_graceful_termination_sec     = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time       = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage           = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay           = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add       = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete    = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure   = auto_scaler_profile.value.scale_down_delay_after_failure
      scale_down_unneeded              = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready               = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold = auto_scaler_profile.value.scale_down_utilization_threshold
      scan_interval                    = auto_scaler_profile.value.scan_interval
      skip_nodes_with_local_storage    = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }
  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade == null ? [] : [var.maintenance_window_auto_upgrade]
    content {
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      duration     = maintenance_window_auto_upgrade.value.duration
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      day_of_month = maintenance_window_auto_upgrade.value.day_of_month
      week_index   = maintenance_window_auto_upgrade.value.week_index
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      start_date   = maintenance_window_auto_upgrade.value.start_date

      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed == null ? [] : maintenance_window_auto_upgrade.value.not_allowed
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }
  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os == null ? [] : [var.maintenance_window_node_os]
    content {
      duration     = maintenance_window_node_os.value.duration
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      day_of_month = maintenance_window_node_os.value.day_of_month
      day_of_week  = maintenance_window_node_os.value.day_of_week
      start_date   = maintenance_window_node_os.value.start_date
      start_time   = maintenance_window_node_os.value.start_time
      utc_offset   = maintenance_window_node_os.value.utc_offset
      week_index   = maintenance_window_node_os.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed == null ? [] : maintenance_window_node_os.value.not_allowed
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control == null ? [] : var.role_based_access_control
    content {
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
      admin_group_object_ids = !azure_active_directory_role_based_access_control.value.azure_rbac_enabled ? var.admin_group_id : null
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
    }
  }
  dynamic "default_node_pool" {
    for_each = var.default_node_pool_config.enable_auto_scaling == true ? [var.default_node_pool_config] : []
    content {
      name                         = default_node_pool.value.name
      vm_size                      = default_node_pool.value.vm_size
      auto_scaling_enabled         = default_node_pool.value.enable_auto_scaling
      host_encryption_enabled      = default_node_pool.value.enable_host_encryption
      max_count                    = default_node_pool.value.max_count
      min_count                    = default_node_pool.value.min_count
      max_pods                     = default_node_pool.value.max_pods
      node_labels                  = default_node_pool.value.node_labels
      node_public_ip_enabled       = default_node_pool.value.enable_node_public_ip
      only_critical_addons_enabled = default_node_pool.value.only_critical_addons_enabled
      orchestrator_version         = default_node_pool.value.orchestrator_version
      os_disk_size_gb              = default_node_pool.value.os_disk_size_gb
      os_disk_type                 = default_node_pool.value.os_disk_type
      os_sku                       = default_node_pool.value.os_sku
      proximity_placement_group_id = default_node_pool.value.proximity_placement_group_id
      type                         = default_node_pool.value.type
      vnet_subnet_id               = default_node_pool.value.vnet_subnet_id
      zones                        = default_node_pool.value.zones
      fips_enabled                 = default_node_pool.value.fips_enabled
      scale_down_mode              = default_node_pool.value.scale_down_mode
      snapshot_id                  = default_node_pool.value.snapshot_id
      temporary_name_for_rotation  = default_node_pool.value.temporary_name_for_rotation
      ultra_ssd_enabled            = default_node_pool.value.ultra_ssd_enabled
      pod_subnet_id                = default_node_pool.value.pod_subnet_id
      tags                         = merge(module.labels.tags, default_node_pool.value.tags)
      dynamic "upgrade_settings" {
        for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]
        content {
          max_surge                     = var.agents_pool_max_surge
          drain_timeout_in_minutes      = var.agents_pool_drain_timeout_in_minutes
          node_soak_duration_in_minutes = var.agents_pool_node_soak_duration_in_minutes
        }
      }
    }
  }
  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender_enabled ? ["microsoft_defender"] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }
  dynamic "oms_agent" {
    for_each = var.oms_agent_enabled ? ["oms_agent"] : []
    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = var.msi_auth_for_monitoring_enabled
    }
  }
  dynamic "service_mesh_profile" {
    for_each = var.service_mesh_profile == null ? [] : [var.service_mesh_profile]
    content {
      mode      = service_mesh_profile.value.mode
      revisions = lookup(service_mesh_profile.value, "revisions", [])
    }
  }
  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []
    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }
  dynamic "storage_profile" {
    for_each = var.storage_profile_enabled ? ["storage_profile"] : []
    content {
      blob_driver_enabled         = var.storage_profile.blob_driver_enabled
      disk_driver_enabled         = var.storage_profile.disk_driver_enabled
      file_driver_enabled         = var.storage_profile.file_driver_enabled
      snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
    }
  }
  identity {
    type         = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? [azurerm_user_assigned_identity.aks_user_assigned_identity[0].id] : []
  }
  dynamic "web_app_routing" {
    for_each = var.web_app_routing == null ? [] : ["web_app_routing"]
    content {
      dns_zone_ids = var.web_app_routing.dns_zone_ids
    }
  }
  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [true] : []
    iterator = lp
    content {
      admin_username = var.linux_profile.username

      ssh_key {
        key_data = var.linux_profile.ssh_key
      }
    }
  }
  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile == null ? [] : [var.workload_autoscaler_profile]
    content {
      keda_enabled                    = workload_autoscaler_profile.value.keda_enabled
      vertical_pod_autoscaler_enabled = workload_autoscaler_profile.value.vertical_pod_autoscaler_enabled
    }
  }
  dynamic "windows_profile" {
    for_each = var.windows_profile != null ? [var.windows_profile] : []
    content {
      admin_username = windows_profile.value.admin_username
      admin_password = windows_profile.value.admin_password
      license        = windows_profile.value.license
      dynamic "gmsa" {
        for_each = windows_profile.value.gmsa != null ? [windows_profile.value.gmsa] : []
        content {
          dns_server  = gmsa.value.dns_server
          root_domain = gmsa.value.root_domain
        }
      }
    }
  }
  network_profile {
    network_plugin      = var.network_plugin
    network_policy      = var.network_policy
    network_data_plane  = var.network_data_plane
    dns_service_ip      = cidrhost(var.service_cidr, 10)
    service_cidr        = var.service_cidr
    load_balancer_sku   = var.load_balancer_sku
    network_plugin_mode = var.network_plugin_mode
    outbound_type       = var.outbound_type
    pod_cidr            = var.net_profile_pod_cidr
    dynamic "load_balancer_profile" {
      for_each = var.load_balancer_profile_enabled && var.load_balancer_sku == "standard" ? [1] : []
      content {
        idle_timeout_in_minutes     = var.load_balancer_profile_idle_timeout_in_minutes
        managed_outbound_ip_count   = var.load_balancer_profile_managed_outbound_ip_count
        managed_outbound_ipv6_count = var.load_balancer_profile_managed_outbound_ipv6_count
        outbound_ip_address_ids     = var.load_balancer_profile_outbound_ip_address_ids
        outbound_ip_prefix_ids      = var.load_balancer_profile_outbound_ip_prefix_ids
        outbound_ports_allocated    = var.load_balancer_profile_outbound_ports_allocated
      }
    }
  }
  depends_on = [
    azurerm_role_assignment.aks_uai_private_dns_zone_contributor,
  ]
  tags = module.labels.tags
}

##-----------------------------------------------------------------------------
## Additional Node Pools
##-----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each                      = var.enable ? var.node_pools : {}
  kubernetes_cluster_id         = azurerm_kubernetes_cluster.aks[0].id
  name                          = each.key
  vm_size                       = each.value.vm_size
  os_type                       = each.value.os_type
  os_disk_type                  = each.value.os_disk_type
  os_disk_size_gb               = each.value.os_disk_size_gb
  vnet_subnet_id                = each.value.vnet_subnet_id
  auto_scaling_enabled          = each.value.enable_auto_scaling
  host_encryption_enabled       = each.value.enable_host_encryption
  node_count                    = each.value.enable_auto_scaling ? null : each.value.node_count
  min_count                     = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count                     = each.value.enable_auto_scaling ? each.value.max_count : null
  max_pods                      = each.value.max_pods
  node_public_ip_enabled        = each.value.enable_node_public_ip
  mode                          = each.value.mode
  orchestrator_version          = each.value.orchestrator_version
  node_taints                   = each.value.node_taints
  host_group_id                 = each.value.host_group_id
  capacity_reservation_group_id = each.value.capacity_reservation_group_id
  workload_runtime              = each.value.workload_runtime
  zones                         = each.value.zones
  fips_enabled                  = each.value.fips_enabled
  kubelet_disk_type             = each.value.kubelet_disk_type
  node_labels                   = each.value.node_labels
  pod_subnet_id                 = each.value.pod_subnet_id
  proximity_placement_group_id  = each.value.proximity_placement_group_id
  scale_down_mode               = each.value.scale_down_mode
  snapshot_id                   = each.value.snapshot_id
  spot_max_price                = each.value.spot_max_price
  tags                          = each.value.tags
  eviction_policy               = each.value.eviction_policy
  gpu_instance                  = each.value.gpu_instance
  os_sku                        = each.value.os_sku
  priority                      = each.value.priority
  temporary_name_for_rotation   = each.value.temporary_name_for_rotation
  ultra_ssd_enabled             = each.value.ultra_ssd_enabled
  dynamic "kubelet_config" {
    for_each = var.kubelet_config != null ? [var.kubelet_config] : []
    content {
      allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
      container_log_max_line    = kubelet_config.value.container_log_max_line
      container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
      cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
      cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
      cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
      image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
      image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
      pod_max_pid               = kubelet_config.value.pod_max_pid
      topology_manager_policy   = kubelet_config.value.topology_manager_policy
    }
  }
  dynamic "linux_os_config" {
    for_each = var.agents_pool_linux_os_configs
    content {
      swap_file_size_mb            = linux_os_config.value.swap_file_size_mb
      transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag
      transparent_huge_page        = linux_os_config.value.transparent_huge_page
      dynamic "sysctl_config" {
        for_each = linux_os_config.value.sysctl_configs == null ? [] : linux_os_config.value.sysctl_configs
        content {
          fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
          fs_file_max                        = sysctl_config.value.fs_file_max
          fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
          fs_nr_open                         = sysctl_config.value.fs_nr_open
          kernel_threads_max                 = sysctl_config.value.kernel_threads_max
          net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
          net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
          net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
          net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
          net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
          net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
          net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
          net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
          net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
          net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
          net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
          net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
          net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
          net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
          net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
          net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
          net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
          net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
          net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
          net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
          net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
          vm_max_map_count                   = sysctl_config.value.vm_max_map_count
          vm_swappiness                      = sysctl_config.value.vm_swappiness
          vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
        }
      }
    }
  }
  dynamic "upgrade_settings" {
    for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]
    content {
      max_surge                     = var.agents_pool_max_surge
      drain_timeout_in_minutes      = var.agents_pool_drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.agents_pool_node_soak_duration_in_minutes
    }
  }
  windows_profile {
    outbound_nat_enabled = var.outbound_nat_enabled
  }
}

##-----------------------------------------------------------------------------
## Key Vault Key for Encryption
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "example" {
  depends_on      = [azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enable && var.cmk_enabled ? 1 : 0
  name            = var.resource_position_prefix ? format("aks-encrypted-key-%s", local.name) : format("%s-aks-encrypted-key", local.name)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = var.cmk_key_type
  key_size        = var.cmk_key_size
  key_opts        = var.cmk_key_ops
  dynamic "rotation_policy" {
    for_each = var.rotation_policy_enabled ? var.rotation_policy : {}
    content {
      automatic {
        time_before_expiry = rotation_policy.value.time_before_expiry
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }
}

##-----------------------------------------------------------------------------
## Disk Encryption Set
##-----------------------------------------------------------------------------
resource "azurerm_disk_encryption_set" "main" {
  count               = var.enable && var.cmk_enabled ? 1 : 0
  name                = var.resource_position_prefix ? format("aks-dsk-encrpted-%s", local.name) : format("%s-aks-dsk-encrpted", local.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = var.key_vault_id != null ? azurerm_key_vault_key.example[0].id : null
  identity {
    type = "SystemAssigned"
  }
}

##-----------------------------------------------------------------------------
## Key Vault Access Policies
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "main" {
  count                   = var.enable && var.cmk_enabled ? 1 : 0
  key_vault_id            = var.key_vault_id
  tenant_id               = azurerm_disk_encryption_set.main[0].identity[0].tenant_id
  object_id               = azurerm_disk_encryption_set.main[0].identity[0].principal_id
  key_permissions         = var.cmk_des_key_permissions
  certificate_permissions = var.cmk_des_certificate_permissions
}

resource "azurerm_key_vault_access_policy" "key_vault" {
  count        = var.enable && var.cmk_enabled ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.enable && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id : azurerm_kubernetes_cluster.aks[0].identity[0].principal_id

  key_permissions         = var.cmk_aks_key_permissions
  certificate_permissions = var.cmk_aks_certificate_permissions
  secret_permissions      = var.cmk_aks_secret_permissions
}

resource "azurerm_key_vault_access_policy" "kubelet_identity" {
  count        = var.enable && var.cmk_enabled ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id

  key_permissions         = var.cmk_kubelet_key_permissions
  certificate_permissions = var.cmk_kubelet_certificate_permissions
  secret_permissions      = var.cmk_kubelet_secret_permissions
}

##-----------------------------------------------------------------------------
## Diagnostic Settings
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "aks_diag" {
  depends_on                     = [azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count                          = var.enable && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-diag-log-%s", local.name) : format("%s-aks-diag-log", local.name)
  target_resource_id             = azurerm_kubernetes_cluster.aks[0].id
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
    for_each = var.kv_logs.enabled ? var.kv_logs.category != null ? var.kv_logs.category : var.kv_logs.category_group : []
    content {
      category       = var.kv_logs.category != null ? enabled_log.value : null
      category_group = var.kv_logs.category == null ? enabled_log.value : null
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

resource "azurerm_monitor_diagnostic_setting" "pip_aks" {
  depends_on                     = [data.azurerm_resources.aks_pip, azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count                          = var.enable && var.diagnostic_setting_enable ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-pip-diag-log-%s", local.name) : format("%s-aks-pip-diag-log", local.name)
  target_resource_id             = data.azurerm_resources.aks_pip[count.index].resources[0].id
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

resource "azurerm_monitor_diagnostic_setting" "aks-nsg" {
  depends_on                     = [data.azurerm_resources.aks_nsg, azurerm_kubernetes_cluster.aks]
  count                          = var.enable && var.diagnostic_setting_enable ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-nsg-diag-log-%s", local.name) : format("%s-aks-nsg-diag-log", local.name)
  target_resource_id             = data.azurerm_resources.aks_nsg[count.index].resources[0].id
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
    for_each = var.kv_logs.enabled ? var.kv_logs.category != null ? var.kv_logs.category : var.kv_logs.category_group : []
    content {
      category       = var.kv_logs.category != null ? enabled_log.value : null
      category_group = var.kv_logs.category == null ? enabled_log.value : null
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

resource "azurerm_monitor_diagnostic_setting" "aks-nic" {
  depends_on                     = [data.azurerm_resources.aks_nic, azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count                          = var.enable && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-nic-dia-log-%s", local.name) : format("%s-aks-nic-dia-log", local.name)
  target_resource_id             = data.azurerm_resources.aks_nic[count.index].resources[0].id
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