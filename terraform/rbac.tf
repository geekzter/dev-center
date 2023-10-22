data azurerm_role_definition allowed_developer_roles {
  for_each                     = toset(["Contributor","Reader"])
  name                         = each.value
}

locals {
  # Constrain what roles can be assigned and who they can be assigned to
  role_assignment_constraint   = templatefile("${path.module}/user-access-administrator-condition-template.txt",
    {
      role_definition_ids      = join(",",[for role in data.azurerm_role_definition.allowed_developer_roles : split("/",role.id)[4]])
      assignee_object_ids      = join(",",distinct(concat([data.azurerm_client_config.current.object_id], var.developer_object_ids)))
    }
  )
}

resource azurerm_user_assigned_identity dev_center_identity {
  name                         = "${azurerm_resource_group.dev_center.name}-identity"
  resource_group_name          = azurerm_resource_group.dev_center.name
  location                     = azurerm_resource_group.dev_center.location
  tags                         = azurerm_resource_group.dev_center.tags
}

resource azurerm_role_assignment dev_center_subscription_contributor {
  scope                        = join("/",slice(split("/",azurerm_resource_group.dev_center.id),0,3))
  role_definition_name         = "Contributor"
  principal_id                 = azurerm_user_assigned_identity.dev_center_identity.principal_id
}
resource azurerm_role_assignment dev_center_subscription_admin {
  scope                        = join("/",slice(split("/",azurerm_resource_group.dev_center.id),0,3))
  role_definition_name         = "User Access Administrator"
  principal_id                 = azurerm_user_assigned_identity.dev_center_identity.principal_id
  condition                    = local.role_assignment_constraint
  condition_version            = "2.0"
}

resource azurerm_role_assignment terraform_project {
  scope                        = azurerm_dev_center_project.project.id
  role_definition_name         = "Deployment Environments User"
  principal_id                 = data.azurerm_client_config.current.object_id
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