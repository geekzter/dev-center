data azurerm_client_config current {}

resource random_string suffix {
  length                       = 4
  upper                        = false
  lower                        = true
  numeric                      = false
  special                      = false
}

locals {
  resource_prefix              = var.resource_prefix != null && var.resource_prefix != "" ? "${var.resource_prefix}-" : ""
}

resource azurerm_resource_group storage {
  name                         = terraform.workspace == "default" ? "${local.resource_prefix}storage-${random_string.suffix.result}" : "${local.resource_prefix}storage-${terraform.workspace}-${random_string.suffix.result}"
  location                     = var.location
  tags                         = {
    application                = "Deployment environment storage account demo"
    provisioner                = "terraform"
    provisionerClientId        = data.azurerm_client_config.current.client_id
    provisionerObjectId        = data.azurerm_client_config.current.object_id
    workspace                  = terraform.workspace
  }
}

resource azurerm_storage_account storage {
  name                         = "${lower(replace(azurerm_resource_group.storage.name,"-",""))}stor"
  location                     = azurerm_resource_group.storage.location
  resource_group_name          = azurerm_resource_group.storage.name
  tags                         = azurerm_resource_group.storage.tags

  account_kind                 = "StorageV2"
  account_tier                 = "Standard"
  account_replication_type     = "LRS"
  allow_nested_items_to_be_public = false
  blob_properties {
    delete_retention_policy {
      days                     = 365
    }
  }
  enable_https_traffic_only    = true
}