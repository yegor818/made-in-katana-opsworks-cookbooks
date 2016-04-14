# Include the attributes set in the mik-setup cookbook as it specifies the
# directories used for the applications. Any changes should be made globally,
# but ensure that there are no applications deployed before making changes.
include_attribute "mik-setup::default"

# Iterate through the applications passed by OpsWorks.
node[:deploy].each do |application, deploy|
  
  Chef::Log.info "MIK: default.rb"
     
  # Set the default application name. AWS OpsWorks does not pass this, so if it
  # is not set manually, then just use the application shortname.
  default[:deploy][application][:name] = application

  # Set the default port number for the web application. If this is modified,
  # ensure the load balancer is equipped to handle the port.
  default[:deploy][application][:nginx][:port] = node[:setup][:nginx][:port]

  # Set the default log and session directories for the application. If using
  # a multi-node cluster, it is a requirement to use database sessions or there
  # will be inconsistencies when dealing with session data.
  default[:deploy][application][:log_dir]     = "#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:document_root]}/logs"
  default[:deploy][application][:session_dir] = "#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:document_root]}/sessions"

  # Set a sub-directory for the source code in the repository if necessary.
  default[:deploy][application][:code_path] = "/src"

  # Determine if there is a document sub-root, which is sometimes needed if the
  # application is not in the top-level of the code repository. If no sub-root
  # is specified, then the document root should be used.
  default[:deploy][application][:current_path]   = "#{node[:deploy][application][:document_root]}/current#{node[:deploy][application][:code_path]}"

  # Set a base path for any applications that require it.
  default[:deploy][application][:base_path] = "#{node[:setup][:nginx][:www_dir]}/#{default[:deploy][application][:current_path]}"

  if deploy[:document_subroot]
    default[:deploy][application][:nginx][:root] = "#{node[:setup][:nginx][:www_dir]}/#{default[:deploy][application][:current_path]}/#{node[:deploy][application][:document_subroot]}"
  else
    default[:deploy][application][:nginx][:root] = "#{node[:setup][:nginx][:www_dir]}/#{default[:deploy][application][:current_path]}"
  end

  # Set the default document indexes in the order of priority, starting at the
  # top. This can be changed if the application requires something different.
  default[:deploy][application][:nginx][:index] = [ "index.html",
                                                    "index.htm",
                                                    "index.php" ]

  # Set the default location of the log files for the application. This can be
  # modified, but is recommended to leave as default for consistency.
  default[:deploy][application][:nginx][:access_log] = "#{node[:deploy][application][:log_dir]}/www-access_log"
  default[:deploy][application][:nginx][:error_log]  = "#{node[:deploy][application][:log_dir]}/www-error_log"

  # Set custom headers to identify the application node serving the request and
  # any other custom requirements for the application.
  default[:deploy][application][:nginx][:headers]['X-Served-By'] = `cat /etc/hostname`.strip

  # Specify the error pages associated with the error codes thrown by Nginx.
  # If an application requires a custom error page, then the relevant code can
  # be overridden. Any new variations can also be added.
  #default[:deploy][application][:nginx][:error_page]["403"] = "/messages/403.html"
  #default[:deploy][application][:nginx][:error_page]["404"] = "/messages/404.html"
  #default[:deploy][application][:nginx][:error_page]["500"] = "/messages/500.html"
  #default[:deploy][application][:nginx][:error_page]["502"] = "/messages/502.html"
  #default[:deploy][application][:nginx][:error_page]["503"] = "/messages/503.html"
  #default[:deploy][application][:nginx][:error_page]["504"] = "/messages/504.html"

  # Set the default arguments in the location blocks. Additional location blocks
  # can easily be added in the array if you require custom rewrite rules etc.
  default[:deploy][application][:nginx][:location]["/"][:autoindex]        = "off"
  default[:deploy][application][:nginx][:location]["/"][:try_files]        = "$uri $uri/ /index.php?$args"
  #default[:deploy][application][:nginx][:location]["^~ /messages/"][:root] = "/usr/share/nginx/html"

  # Set the default name for the PHP-FPM socket file.
  default[:deploy][application][:php][:socket_name] = "php-fpm.#{node[:deploy][application][:document_root].sub("/", "-")}.sock"

  # Specify the default process configuration for PHP-FPM. This should be
  # adjusted if an application requires capacity for a larger amount of traffic,
  # or even if it only receives little traffic.
  default[:deploy][application][:php][:max_children]      = 30
  default[:deploy][application][:php][:start_servers]     = 5
  default[:deploy][application][:php][:min_spare_servers] = 5
  default[:deploy][application][:php][:max_spare_servers] = 10
  default[:deploy][application][:php][:max_requests]      = 300

  # Set the default slow log timeout. This can be increased or decreased for
  # debugging performance implications on applications.
  default[:deploy][application][:php][:slowlog_timeout] = "5s"

  # Set any php_flag variables and their value. Acceptable values for php_flag
  # are: on, off, 0, 1.
  default[:deploy][application][:php][:php_flag][:display_errors] = "on"

  # Set any php_value variables and their value. Acceptable values for php_value
  # can be any integer or string, depending on the variable specification.
  default[:deploy][application][:php][:php_value]["session.save_handler"] = "files"
  default[:deploy][application][:php][:php_value]["session.save_path"]    = "#{node[:deploy][application][:session_dir]}"

  # Set any php_admin_flag variables and their value. The php_admin_flag
  # variables will permanently enforce the flag and not allow user override.
  # Acceptable values for php_admin_flag are: on, off, 0, 1.
  default[:deploy][application][:php][:php_admin_flag][:log_errors] = "on"

  # Set any php_admin_value variables and their value. The php_admin_value
  # variables will permanently enforce the value and not allow user override.
  # Acceptable values for php_admin_value can be any integer or string,
  # depending on the variable specification.
  default[:deploy][application][:php][:php_admin_value][:memory_limit] = "128M"
  default[:deploy][application][:php][:php_admin_value][:error_log]    = "#{node[:deploy][application][:log_dir]}/php-error_log"

  if node[:setup][:environment]
    default[:deploy][application][:php][:php_admin_value]['newrelic.appname'] = "\"#{node[:deploy][application][:name]} (#{node[:setup][:environment].capitalize})\""
  else
    default[:deploy][application][:php][:php_admin_value]['newrelic.appname'] = "\"#{node[:deploy][application][:name]}\""
  end

  # Set application debug to be off. This is generally just a true or false
  # value which can be used in a template. It needs to manually be added to the
  # .ERB file in your code repository.
  default[:deploy][application][:debug] = "false"

  # Set the default Yii configuration for applications that require the shared
  # Yii library stored on the servers. The version can be manually overridden
  # for applications if required.
  default[:deploy][application][:yii][:location] = "yii"
  default[:deploy][application][:yii][:version]  = "1.1.14"

  # Set the home directory for the application. This should always be the root
  # application directory. Overriding this may cause permission issues.
  default[:deploy][application][:home_dir] = "#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:document_root]}"

  # If the application has a user and group ID set in the JSON string, then
  # set the username to be the application shortname. If no user or group ID has
  # been specified, then use the Nginx default user.
  default[:deploy][application][:user_name]  = application[0, 32]
  default[:deploy][application][:group_name] = application[0, 32]

end
