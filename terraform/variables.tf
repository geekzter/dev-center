variable application_name {
  description                  = "Value of 'application' resource tag"
  default                      = "Development Center"
}
variable application_owner {
  description                  = "Value of 'owner' resource tag"
  default                      = "" # Empty string takes objectId of current user
}

variable location {
  default                      = "westeurope"
  nullable                     = false
}

variable resource_prefix {
  description                  = "The prefix to put at the of resource names created"
  default                      = "dev"
}
variable resource_suffix {
  description                  = "The suffix to put at the of resource names created"
  default                      = "" # Empty string triggers a random suffix
}
variable run_id {
  description                  = "The ID that identifies the pipeline / workflow that invoked Terraform"
  default                      = ""
}