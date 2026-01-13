variable "client_name" {
  type        = string
  description = "Name of the client defaults to test001 if not set."
}

variable "resource_group" {
  description = "resource group object from top level module"
}