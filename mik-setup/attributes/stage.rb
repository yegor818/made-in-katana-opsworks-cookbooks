if node[:setup][:environment] == "stage"

  # Set the default variables for the NFS mount. By default, if these are left
  # blank or as their defaults, then the NFS partition will not be mounted.
  default[:setup][:nfs][:host]        = "172.16.2.96"
  default[:setup][:nfs][:target]      = "/mnt/mik-www-stage"
  default[:setup][:nfs][:mount_point] = "/mnt/mik-www-stage"

end
