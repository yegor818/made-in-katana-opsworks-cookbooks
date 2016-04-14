if node[:setup][:environment] == "production"

  # Set the default variables for the NFS mount. By default, if these are left
  # blank or as their defaults, then the NFS partition will not be mounted.
  default[:setup][:nfs][:host]        = "172.16.0.74"
  default[:setup][:nfs][:target]      = "/mnt/mik-www-prod"
  default[:setup][:nfs][:mount_point] = "/mnt/mik-www-prod"

end
