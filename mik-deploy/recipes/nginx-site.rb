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

  # Create the Nginx site configuration file based on the ERB template.
  template "#{node[:setup][:nginx][:site_dir]}/#{filename}.conf" do
    source "nginx-site.conf.erb"
    owner "root"
    mode 0644
    variables (:application => node[:deploy][application])
    notifies :reload, "service[nginx]", :delayed
  end

  # If the log directory does not already exist, which it probably will not,
  # then create it and set the correct permissions.
  directory node[:deploy][application][:log_dir] do
    owner node[:setup][:nginx][:user_name]
    group node[:setup][:nginx][:group_name]
    mode 0755
    recursive true
    action :create
  end

  # Create the access_log file, if it does not already exist, and set the
  # correct permissions.
  file node[:deploy][application][:nginx][:access_log] do
    owner node[:setup][:nginx][:user_name]
    group node[:setup][:nginx][:group_name]
    mode 0640
    action :create
  end

  # Create the error_log file, if it does not already exist, and set the
  # correct permissions.
  file node[:deploy][application][:nginx][:error_log] do
    owner node[:setup][:nginx][:user_name]
    group node[:setup][:nginx][:group_name]
    mode 0640
    action :create
  end

  # Fix the permissions for any modified files.
  fix_application_perms do
    application_name application
  end

end
