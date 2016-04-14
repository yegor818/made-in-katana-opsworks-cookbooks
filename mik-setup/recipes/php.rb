# Install all of the necessary packages for PHP to operate on this system.
# The current release of PHP is version 5.3 - newer versions have not yet been
# tested.
#
# To add another package, simply add the YUM package name to the list. Please
# note that it must be in the correct order of dependencies or installation may
# fail.
package "php-cli"
package "php-fpm"
package "php-gd"
package "php-intl"
package "php-mbstring"
package "php-mcrypt"
package "php-mysql"
package "php-process"
package "php-pecl-imagick"
package "php-pecl-memcache"
package "php-pecl-oauth"
package "php-pecl-xdebug"
package "php-soap"
package "php-xcache"
package "php-xml"
package "php-xmlrpc"
package "php-xsl"

# Create the global PHP configuration based on the template in this cookbook.
# This should be consistent on each node running PHP for load-balanced clusters.
template "php.ini" do
  path "#{node[:setup][:php][:conf_dir]}/php.ini"
  source "php.ini.erb"
  owner "root"
  group "root"
  mode 0644
end

# Delete the default PHP-FPM pool configuration because the default one is not
# required. Instead, create one based on the template in this cookbook.
file "#{node[:setup][:php][:site_dir]}/www.conf" do
  action :delete
end

template "default.conf" do
  path "#{node[:setup][:php][:site_dir]}/default.conf"
  source "php-default.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

# Enable the PHP-FPM service in the server startup configuration and trigger a
# start event to fire it up.
service "php-fpm" do
  supports :status => true, :start => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
