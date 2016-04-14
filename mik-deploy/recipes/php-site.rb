# Include the service recipe which defines the service and its parameters.
include_recipe "mik-deploy::service"

# Iterate through the applications passed by OpsWorks.
node[:deploy].each do |application, deploy|

  # If the application was not in the JSON string passed by OpsWorks, then it
  # should not be modified in any way.
  if !node[:deploy][application][:application] or node[:deploy][application][:document_root].empty?
    next
  end

  # Create user and groups for application.
  create_application_ids do
    application_name application
  end

  # Check to make sure the users were created. If they were, then let the
  # process to continue, otherwise move on to the next application.
  if node[:deploy][application][:fail] == 1
    next
  end

  # Set the filename variable based on the document root. If a sub-directory
  # has been specified, then replace the '/' with '-' to keep it as a file.
  filename = node[:deploy][application][:document_root].sub("/", "-")

  # Create the PHP-FPM site configuration file based on the ERB template.
  template "#{node[:setup][:php][:site_dir]}/#{filename}.conf" do
    source "php-site.conf.erb"
    owner "root"
    mode 0644
    variables (:application => node[:deploy][application])
    notifies :reload, "service[php-fpm]", :delayed
  end

  # Create the session data directory, if it does not already exist. The owner
  # and group should be set to the same as Nginx as it will be the one that
  # reads from this directory.
  directory "#{node[:deploy][application][:session_dir]}" do
    owner node[:setup][:nginx][:user_name]
    group node[:setup][:nginx][:group_name]
    mode 0755
    recursive true
    action :create
  end

  # Fix the permissions for any modified files.
  fix_application_perms do
    application_name application
  end

end
