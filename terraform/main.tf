data azurerm_client_config current {}
data azurerm_subscription primary {}

resource random_string suffix {
  length                       = 4
  upper                        = false
  lower                        = true
  numeric                      = false
  special                      = false
}

locals {
  owner                        = var.application_owner != "" ? var.application_owner : data.azurerm_client_config.current.object_id
  resource_suffix              = var.resource_suffix != null && var.resource_suffix != "" ? var.resource_suffix : random_string.suffix.result
}

resource azurerm_resource_group dev_center {
  name                         = terraform.workspace == "default" ? "${var.resource_prefix}-center-${local.resource_suffix}" : "${var.resource_prefix}-center-${terraform.workspace}-${local.resource_suffix}"
  location                     = var.location
  tags                         = {
    application                = var.application_name
    environment                = "dev"
    owner                      = local.owner
    provisioner                = "terraform"
    provisioner-client-id      = data.azurerm_client_config.current.client_id
    provisioner-object-id      = data.azurerm_client_config.current.object_id
    repository                 = "dev-center"
    runid                      = var.run_id
    suffix                     = local.resource_suffix
    workspace                  = terraform.workspace
  }
}

resource azurerm_user_assigned_identity dev_center_identity {
  name                         = "${azurerm_resource_group.dev_center.name}-identity"
  resource_group_name          = azurerm_resource_group.dev_center.name
  location                     = azurerm_resource_group.dev_center.location
  tags                         = azurerm_resource_group.dev_center.tags
}

resource azurerm_dev_center dev_center {
  name                         = azurerm_resource_group.dev_center.name
  resource_group_name          = azurerm_resource_group.dev_center.name
  location                     = azurerm_resource_group.dev_center.location
  tags                         = azurerm_resource_group.dev_center.tags

  identity {
    type                       = "UserAssigned"
    identity_ids               = [azurerm_user_assigned_identity.dev_center_identity.id]
  }
}

resource azurerm_dev_center_project project {
  name                         = "${azurerm_dev_center.dev_center.name}-project"
  resource_group_name          = azurerm_resource_group.dev_center.name
  location                     = azurerm_resource_group.dev_center.location
  tags                         = azurerm_resource_group.dev_center.tags
  dev_center_id                = azurerm_dev_center.dev_center.id
}