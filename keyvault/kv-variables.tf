variable "location" {
  type        = string
  description = "location for the resources to be created."
}

variable "client_name" {
  type        = string
  description = "Name of the client defaults to test001 if not set."
}

variable "resource_group" {
  description = "resource group object from top level module"
}

variable "readers" {
  type        = list(string)
  description = "defualt readers for keyvault"
}

variable "contributors" {
  type        = list(string)
  description = "default contributors for keyvault"
}
