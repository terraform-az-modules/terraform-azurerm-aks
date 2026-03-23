# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.4] - 2026-03-23
### :bug: Bug Fixes
- [`4592775`](https://github.com/terraform-az-modules/terraform-azurerm-aks/commit/459277555dce2f7a68672c88ccc440cfbb3518f3) - Updated logic for node resource group name *(PR [#128](https://github.com/terraform-az-modules/terraform-azurerm-aks/pull/128) by [@maharshi-cd](https://github.com/maharshi-cd))*


## [1.0.2] - 2026-03-20

### Changes
- Add provider_meta for API usage tracking
- Add terraform test files and pre-commit CI workflow
- Add wrapper module for Terragrunt support
- Add SECURITY.md, CONTRIBUTING.md, .releaserc.json
- Standardize pre-commit to antonbabenko/pre-commit-terraform v1.105.0
- Set provider: none in tf-checks for validate-only CI
- Use pr-checks.yml (hyphen) for PR validation
- Bump required_version to >= 1.10.0
- Fix shared workflow tag references

## [1.0.1] - 2025-12-15

### Changes
- Add backup support for AKS clusters
- Add ingress controller example
- Add Microsoft Entra ID integration example
- Update azurerm provider to >= 4.31.0

## [1.0.0] - 2025-09-01

### Initial Release
- Azure Kubernetes Service module with public and private cluster support
- Node pool management with autoscaling
- Diagnostic settings integration
- Key Vault integration for secrets
- RBAC and Microsoft Entra ID support
- Backup and restore capabilities
[v1.0.4]: https://github.com/terraform-az-modules/terraform-azurerm-aks/compare/v1.0.3...v1.0.4
