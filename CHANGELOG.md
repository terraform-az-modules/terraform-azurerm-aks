# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
