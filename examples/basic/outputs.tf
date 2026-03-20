output "aks_id" {
  description = "The ID of the AKS cluster"
  value       = module.aks.aks_id
}

output "fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks.fqdn
}
