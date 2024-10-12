locals {
  containers = flatten([
    for sftp_key, sftp in var.SFTP : [
      for cont in sftp.containers : 
        {
          storage_name = sftp_key,
          cont_name    = cont.name
        }
    ]
  ])

  sftpusers = flatten([
    for sftp_key, sftp in var.SFTP : [
      for user in sftp.users : 
        {
          storage_name = sftp_key,
          user_name    = user.name
          key_enabled  = user.ssh_key_enabled
          home_directory = user.home_directory
          permissions_scopes = user.permissions_scopes
          keys = user.ssh_authorized_keys
        }
    ]
  ])

  sftp_users_permissions = [
    "All",
    "Read",
    "Write",
    "List",
    "Delete",
    "Create",
  ]

}