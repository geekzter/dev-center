terraform {
  required_providers {
    azurerm                    = "~> 3.77"
    random                     = "~> 3.1"
  }
  required_version             = "~> 1.0"
}

# Microsoft Azure Resource Manager Provider
provider azurerm {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration   = true
}
