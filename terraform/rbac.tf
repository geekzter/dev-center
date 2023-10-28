data azurerm_role_definition allowed_developer_roles {
  for_each                     = toset([
    "Contributor",
    "Reader"
  ])
  name                         = each.value
}

locals {
  developer_object_ids         = distinct(concat([data.azurerm_client_config.current.object_id], var.developer_object_ids))
  # Constrain what roles can be assigned and who they can be assigned to
  role_assignment_constraint   = templatefile("${path.module}/user-access-administrator-condition-template.txt",
    {
      role_definition_ids      = join(",",[for role in data.azurerm_role_definition.allowed_developer_roles : split("/",role.id)[4]])
      assignee_object_ids      = join(",",local.developer_object_ids)
    }
  )
  subscription_resource_id     = join("/",slice(split("/",azurerm_resource_group.dev_center.id),0,3))
}

resource azurerm_user_assigned_identity dev_center_identity {
  name                         = "${azurerm_resource_group.dev_center.name}-identity"
  resource_group_name          = azurerm_resource_group.dev_center.name
  location                     = azurerm_resource_group.dev_center.location
  tags                         = azurerm_resource_group.dev_center.tags
}

resource azurerm_role_assignment dev_center_subscription_contributor {
  scope                        = local.subscription_resource_id
  role_definition_name         = "Contributor"
  principal_id                 = azurerm_user_assigned_identity.dev_center_identity.principal_id

  count                        = var.configure_rbac ? 1 : 0
}
resource azurerm_role_assignment dev_center_subscription_admin {
  scope                        = local.subscription_resource_id
  role_definition_name         = "User Access Administrator"
  principal_id                 = azurerm_user_assigned_identity.dev_center_identity.principal_id
  condition                    = local.role_assignment_constraint
  condition_version            = "2.0"

  count                        = var.configure_rbac ? 1 : 0
}

resource azurerm_role_assignment developer_environment_access {
  for_each                     = var.configure_rbac ? toset(local.developer_object_ids) : toset([])

  scope                        = azurerm_dev_center_project.project.id
  role_definition_name         = "Deployment Environments User"
  principal_id                 = each.value
}

resource azurerm_role_assignment dev_center_vault {
  scope                        = azurerm_key_vault.vault.id
  role_definition_name         = "Key Vault Secrets User"
  principal_id                 = azurerm_user_assigned_identity.dev_center_identity.principal_id

  count                        = var.configure_rbac ? 1 : 0
}
resource azurerm_role_assignment terraform_vault {
  scope                        = azurerm_key_vault.vault.id
  role_definition_name         = "Key Vault Secrets Officer"
  principal_id                 = data.azurerm_client_config.current.object_id

  count                        = var.configure_rbac ? 1 : 0
}