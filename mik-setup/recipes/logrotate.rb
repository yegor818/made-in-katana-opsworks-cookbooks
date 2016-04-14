# Configure the logrotate service so Nginx and PHP-FPM log files are rotated,
# compressed and archived to a remote service.
template "logrotate-nginx" do
  path "#{node[:setup][:logrotate][:conf_dir_ext]}/nginx"
  source "logrotate-nginx.erb"
  owner "root"
  group "root"
  mode 0644
end

template "logrotate-php" do
  path "#{node[:setup][:logrotate][:conf_dir_ext]}/php-fpm"
  source "logrotate-php.erb"
  owner "root"
  group "root"
  mode 0644
end
