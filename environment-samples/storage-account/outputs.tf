output blob_url {
  value                        = azurerm_storage_account.storage.primary_blob_endpoint
}

output resource_group_portal_url {
  value                        = "https://portal.azure.com/#@${data.azurerm_client_config.current.tenant_id}/resource${azurerm_resource_group.storage.id}/overview"
}