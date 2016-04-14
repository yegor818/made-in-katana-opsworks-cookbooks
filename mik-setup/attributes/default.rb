# Set the default timezone for the servers.
default[:setup][:timezone] = 'Australia/Sydney'

# Set default variables for the Nginx and PHP configurations. These will default
# across all instances, but can be overridden using JSON in OpsWorks. It is
# important that none of the configuration directories are altered after at
# least one server has been deployed unless you know what you're doing. You have
# been warned well in advance.
default[:setup][:nginx][:user_name]            = "nginx"
default[:setup][:nginx][:group_name]           = "nginx"

if `echo $(id nginx > /dev/null 2> /dev/null) $?`[0,1] == "0"
  default[:setup][:php][:user_name]            = node[:setup][:nginx][:user_name]
  default[:setup][:php][:group_name]           = node[:setup][:nginx][:group_name]
else
  default[:setup][:php][:user_name]            = "nobody"
  default[:setup][:php][:group_name]           = "nobody"
end

default[:setup][:nginx][:conf_dir]             = "/etc/nginx"
default[:setup][:nginx][:log_dir]              = "/var/log/nginx"
default[:setup][:nginx][:site_dir]             = "/etc/nginx/conf.d"
default[:setup][:nginx][:www_dir]              = "/app"

default[:setup][:php][:conf_dir]               = "/etc"
default[:setup][:php][:conf_dir_ext]           = "/etc/php.d"
default[:setup][:php][:log_dir]                = "/var/log/php-fpm"
default[:setup][:php][:site_dir]               = "/etc/php-fpm.d"

default[:setup][:cron][:cron_dir]              = "/etc/cron.d"

default[:setup][:framework][:base_dir]         = "/usr/lib"

default[:setup][:framework][:yii][:path]       = "#{node[:setup][:framework][:base_dir]}/yii"
default[:setup][:framework][:yii][:repository] = "http://opsworks:ChUbrErUqay5c2aS@git.madeinkatana.com/dev/yii-framework.git"
default[:setup][:framework][:yii][:revision]   = "master"

# Set some default variables for the global configuration of Nginx. These can be
# changed at any point, but do note that they may impact on server performance.
default[:setup][:nginx][:port]                          = 80

default[:setup][:nginx][:client_max_body_size]          = "128m"

default[:setup][:nginx][:gzip]                          = "on"
default[:setup][:nginx][:gzip_static]                   = "on"
default[:setup][:nginx][:gzip_vary]                     = "on"
default[:setup][:nginx][:gzip_disable]                  = "MSIE [1-6].(?!.*SV1)"
default[:setup][:nginx][:gzip_http_version]             = "1.0"
default[:setup][:nginx][:gzip_comp_level]               = "2"
default[:setup][:nginx][:gzip_proxied]                  = "any"
default[:setup][:nginx][:gzip_types]                    = [ "text/plain",
                                                            "text/html",
                                                            "text/css",
                                                            "application/x-javascript",
                                                            "text/xml",
                                                            "application/xml",
                                                            "application/xml+rss",
                                                            "text/javascript" ]

default[:setup][:nginx][:proxy_buffering]               = "off"
default[:setup][:nginx][:fastcgi_keep_conn]             = "on"

default[:setup][:nginx][:sendfile]                      = "on"

default[:setup][:nginx][:keepalive]                     = "on"
default[:setup][:nginx][:keepalive_timeout]             = 65

default[:setup][:nginx][:worker_processes]              = 1
default[:setup][:nginx][:worker_connections]            = 1024
default[:setup][:nginx][:server_names_hash_bucket_size] = 512

default[:setup][:nginx][:real_ip_header]                = "X-Forwarded-For"
default[:setup][:nginx][:set_real_ip_from]              = "0.0.0.0/0"

default[:setup][:nginx][:proxy_connect_timeout]         = "10800s"
default[:setup][:nginx][:proxy_send_timeout]            = "10800s"
default[:setup][:nginx][:proxy_read_timeout]            = "10800s"
default[:setup][:nginx][:send_timeout]                  = "10800s"

# Set some default variables for the global configuration of PHP. These can be
# changed at any point, but do note that they may impact on server performance.
default[:setup][:php][:short_open_tag] = "on"

default[:setup][:php][:output_buffering] = "off"
default[:setup][:php]['zlib.output_compression'] = "off"

# Set some default veriables for log management on the server.
default[:setup][:logrotate][:conf_dir_ext] = "/etc/logrotate.d"

# Initialise the default variables for the NFS mount. By default, if these are
# left blank, then the NFS partition will not be mounted.
default[:setup][:nfs][:host]          = ""
default[:setup][:nfs][:target]        = ""
default[:setup][:nfs][:mount_point]   = ""
default[:setup][:nfs][:mount_options] = "rw,soft,rsize=16384,wsize=16384,noatime"

# If an environment has been specified, then override the variables for the
# specific environment using anything in its attributes file.
include_attribute "mik-setup::stage"
include_attribute "mik-setup::production"
