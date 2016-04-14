# Include the service recipe which defines the service and its parameters.
include_recipe "mik-deploy::service"

# Iterate through the applications passed by OpsWorks.
node[:deploy].each do |application, deploy|

  # If the application was not in the JSON string passed by OpsWorks, then it
  # should not be modified in any way.
  if !deploy[:application]
    next
  end

  # Set the filename variable based on the document root. If a sub-directory
  # has been specified, then replace the '/' with '-' to keep it as a file.
  filename = deploy[:document_root].sub("/", "-")

  # Delete the Nginx site configuration file and issue an immediate reload.
  file "#{node[:setup][:nginx][:site_dir]}/#{filename}.conf" do
    action :delete
    notifies :reload, "service[nginx]", :immediately
  end

end
