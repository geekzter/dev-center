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

resource azurerm_role_assignment dev_center_subscription {
  for_each                     = toset(["Contributor","User Access Administrator"])

  scope                        = join("/",slice(split("/",azurerm_resource_group.dev_center.id),0,3))
  role_definition_name         = each.value
  principal_id                 = azurerm_user_assigned_identity.dev_center_identity.principal_id
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

resource azurerm_log_analytics_workspace monitor {
  name                         = "${azurerm_resource_group.dev_center.name}-logs"
  location                     = azurerm_resource_group.dev_center.location
  resource_group_name          = azurerm_resource_group.dev_center.name
  tags                         = azurerm_resource_group.dev_center.tags

  sku                          = "PerGB2018"
  retention_in_days            = 30
}
resource azurerm_monitor_diagnostic_setting dev_center {
  name                         = "${azurerm_resource_group.dev_center.name}-logs"
  target_resource_id           = azurerm_dev_center.dev_center.id
  log_analytics_workspace_id   = azurerm_log_analytics_workspace.monitor.id

  enabled_log {
    category_group             = "allLogs"
  }
  enabled_log {
    category_group             = "audit"
  }

  metric {
    category                   = "AllMetrics"
  }
}
resource azurerm_dev_center_project project {
  name                         = "${azurerm_dev_center.dev_center.name}-project"
  resource_group_name          = azurerm_resource_group.dev_center.name
  location                     = azurerm_resource_group.dev_center.location
  tags                         = azurerm_resource_group.dev_center.tags
  dev_center_id                = azurerm_dev_center.dev_center.id
}
resource azurerm_role_assignment terraform_project {
  scope                        = azurerm_dev_center_project.project.id
  role_definition_name         = "Deployment Environments User"
  principal_id                 = data.azurerm_client_config.current.object_id
}

resource azurerm_key_vault vault {
  name                         = "${azurerm_resource_group.dev_center.name}-vlt"
  location                     = azurerm_resource_group.dev_center.location
  resource_group_name          = azurerm_resource_group.dev_center.name
  tags                         = azurerm_resource_group.dev_center.tags

  enable_rbac_authorization    = true
  enabled_for_template_deployment = true
  purge_protection_enabled     = false
  tenant_id                    = data.azurerm_client_config.current.tenant_id
  sku_name                     = "standard"
}

resource azurerm_role_assignment dev_center_vault {
  scope                        = azurerm_key_vault.vault.id
  role_definition_name         = "Key Vault Secrets User"
  principal_id                 = azurerm_user_assigned_identity.dev_center_identity.principal_id
}
resource azurerm_role_assignment terraform_vault {
  scope                        = azurerm_key_vault.vault.id
  role_definition_name         = "Key Vault Secrets Officer"
  principal_id                 = data.azurerm_client_config.current.object_id
}

resource azurerm_key_vault_secret github_token {
  name                         = "github-token"
  value                        = var.github_token
  key_vault_id                 = azurerm_key_vault.vault.id

  count                        = var.github_token != null ? 1 : 0
  depends_on                   = [azurerm_role_assignment.terraform_vault]
}