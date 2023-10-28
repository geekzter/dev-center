output dev_center_url {
  value                        = azurerm_dev_center.dev_center.dev_center_uri
}

output dev_center_principal_id {
  value                        = azurerm_user_assigned_identity.dev_center_identity.principal_id
}

output developer_portal_url {
  value                        = "https://devportal.microsoft.com/"
}

output github_token_id {
  value                        = var.github_token != null ? azurerm_key_vault_secret.github_token.0.versionless_id : null
}

output key_vault_url {
  value                        = azurerm_key_vault.vault.vault_uri
}

output resource_group_id {
  value                        = azurerm_resource_group.dev_center.id
}

output resource_group_portal_url {
  value                        = "https://portal.azure.com/#@${data.azurerm_client_config.current.tenant_id}/resource${azurerm_resource_group.dev_center.id}/overview"
}