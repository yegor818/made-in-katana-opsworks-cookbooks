# Install all of the necessary packages for NFS to operate on this system. This
# will allow the system to mount the NFS partition type for the shared storage
# between nodes for applications.
package "nfs-utils"

# Check if the required variables for NFS have been set and are not empty.
if node[:setup][:nfs][:host].length > 0 && node[:setup][:nfs][:target].length > 0 && node[:setup][:nfs][:mount_point].length > 0

  # Create the directory where the NFS partition will be mounted. This needs to
  # be created first, or the mount will fail.
  directory node[:setup][:nfs][:mount_point] do
    owner "root"
    group "root"
    mode 0755
    action :create
  end

  # Mount the NFS partition to the local mount point and add it to the
  # /etc/fstab file so it automatically mounts when the system boots.
  mount node[:setup][:nfs][:mount_point] do
    device "#{node[:setup][:nfs][:host]}:#{node[:setup][:nfs][:target]}"
    fstype "nfs"
    options node[:setup][:nfs][:mount_options]
    action [:mount, :enable]
  end

else

  log "message" do
    message "MIK-SETUP: Unable to configure NFS as the required settings have not been specified."
    level :info
  end

end
