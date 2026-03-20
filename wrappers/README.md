# Wrapper Module for Terragrunt

This module provides a wrapper around the root module to support creating multiple instances using Terragrunt.

## Usage with Terragrunt

```hcl
terraform {
  source = "git::https://github.com/terraform-az-modules/terraform-azurerm-aks//wrappers?ref=master"
}

inputs = {
  defaults = {
    environment = "dev"
    label_order = ["name", "environment"]
  }

  items = {
    instance1 = {
      name = "example-1"
    }
    instance2 = {
      name = "example-2"
      environment = "staging"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| items | Map of items to create multiple module instances | any | {} |
| defaults | Default values for module instances | any | {} |

## Outputs

| Name | Description |
|------|-------------|
| wrapper | Map of all module instance outputs |
