  SFTP = {
    s1 = {
      containers = [
        {
          name = "Reports"
        }
      ]
      users = [
        {
          name           = "Wolfgang"
          home_directory = "Reports/data"
          permissions_scopes = [
            {
              target_container = "Reports"
              permissions      = ["All"]
            }
          ]
          ssh_authorized_keys = [{
            key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDA53jHqgWWzmZu1EBAsW67Uisl0bKVPnHZBjYbIZFnRA6PJ0b6eV8Dy6KhWg9LsxFm3/+VmHdHcOT3KZUP1pGT+K79WEk0uF8C2kQPVEme87JcdkAV2V1j0ewT98jMqdwGib8mxHQs1gxPnc5fMn4k/WLqhrQIF7lY/SMDvElpKS7wYN9vYUTBNJUE4U2AmN4T+4KrLZOHlQfA+nohwaB95dLphpZOf2kc96Ag7aVJvm+QUrL1vKj3Vs+XOOleUGbtDJ7Z/BmXtgGrj/Pgy1EDyTVJKkrpvyOrTs7i+TpxQ3nMFARg9yuBOjUVs7ncj8ts1lJay4mD+ZGygHVmnrbLelV/ShTYkHF5wY0O72lK4xAAspGG3gGuxv/CuaofbrQvfRHI9quXUv6BMVYcGlZpKxq+Xj+Cn0nvHB60Y0mjAFzMKwxPG6grtmX1HOZeFcl+se1Yk1UgSeMn/wCuCJfbcXHIkdK290ietJY6ZEmS+QQ8+WKn3AZQ4yK8ThBHN1M= wolfgang"
            description = "wolfgang"
          }]
        }
      ]
  } 
  }