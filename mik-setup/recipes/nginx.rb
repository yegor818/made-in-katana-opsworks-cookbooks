# Install all of the necessary packages for Nginx to operate on this system. Any
# release on Nginx should be fine - there are no direct ties to PHP so the PHP
# version does not need to be specific either.
package "nginx"

# Create the directories and fix their permissions to which this particular
# setup requires, if they do not already exist. The node[:mik_deploy][:www_dir]
# *should* already be created in OpsWorks using the partition manager - if it is
# NOT, then you will run out of disk space very quickly.
directory node[:setup][:nginx][:conf_dir] do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

directory node[:setup][:nginx][:log_dir] do
  owner "nginx"
  group "nginx"
  mode 0755
  recursive true
  action :create
end

directory node[:setup][:nginx][:site_dir] do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

directory node[:setup][:nginx][:www_dir] do
  owner "root"
  group "root"
  mode 0755
  recursive true
  action :create
end

# Create the global Nginx configuration based on the template in this cookbook.
# This should be consistent on each node running Nginx for load-balanced
# clusters or you will notice varied performance.
template "nginx.conf" do
  path "#{node[:setup][:nginx][:conf_dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

# Create the default Nginx site. This will be used when the web server is
# reached without a valid virtual host URL specified, or by directly accessing
# the IP address.
template "default.conf" do
  path "#{node[:setup][:nginx][:site_dir]}/default.conf"
  source "nginx-default.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

# Add the index.html template to the default root directory for when a domain is
# not yet configured.
template "index.html" do
  path "/usr/share/nginx/html/index.html"
  source "index.html.erb"
  owner "root"
  group "root"
  mode "0644"
end

# Enable the Nginx service in the server startup configuration and trigger a
# start event to fire it up.
service "nginx" do
  supports :status => true, :start => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
