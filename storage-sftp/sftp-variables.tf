variable "client_name" {
  type        = string
}

variable "resource_group" {
  type        = any
}

variable "keyvault_id" {
  type        = string
  description = "key vault Id for the envirionment"
}

variable "random_s4" {
  type = string
}

variable "SFTP" {
  type = map(object({
      containers = list(object({
        name                  = string
        container_access_type = optional(string)
        metadata              = optional(map(string))
      }))
      users = list(object({
        name            = string
        home_directory  = optional(string)
        ssh_key_enabled = optional(bool, true)
        permissions_scopes = list(object({
          target_container = string
          permissions      = optional(list(string), ["All"])
        }))
        ssh_authorized_keys = optional(list(object({
          key         = string
          description = optional(string)
        })), [])
      }))
    }))
  }