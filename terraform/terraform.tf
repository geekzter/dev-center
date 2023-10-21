terraform {
  required_providers {
    # azuread                    = "~> 2.12"
    azurerm                    = "~> 3.77"
    # cloudinit                  = "~> 2.2"
    # external                   = "~> 2.1"
    # http                       = "~> 2.2"
    # local                      = "~> 2.2"
    # null                       = "~> 3.1"
    random                     = "~> 3.1"
    # time                       = "~> 0.7"
    # tls                        = "~> 3.4"
  }
  required_version             = "~> 1.0"
}

# Microsoft Azure Resource Manager Provider
provider azurerm {
  features {
    # key_vault {
    #   purge_soft_delete_on_destroy = false
    # }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    # template_deployment {
    #   delete_nested_items_during_deletion = false
    # }
    # virtual_machine {
    #   # Don't do this in production
    #   delete_os_disk_on_deletion = true
    # }
  }
}
