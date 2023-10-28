variable application_name {
  description                  = "Value of 'application' resource tag"
  default                      = "Development Center"
}
variable application_owner {
  description                  = "Value of 'owner' resource tag"
  default                      = "" # Empty string takes objectId of current user
}

variable developer_object_ids {
  description                  = "Object IDs of developers (User or Group) that should be granted access to the Dev Center"
  type                         = list(string)
  default                      = []
}

variable github_token {
  description                  = "GitHub personal access token for access to catalog repo(s)"
  default                      = null
}

variable location {
  default                      = "westeurope"
  nullable                     = false
}

variable resource_prefix {
  description                  = "The prefix to put at the of resource names created"
  default                      = "dev"
}
variable resource_group_name {
  description                  = "Override the name of the resource group to create with a specific value"
  default                      = null
}
variable resource_suffix {
  description                  = "The suffix to put at the of resource names created"
  default                      = "" # Empty string triggers a random suffix
}
variable run_id {
  description                  = "The ID that identifies the pipeline / workflow that invoked Terraform"
  default                      = ""
}