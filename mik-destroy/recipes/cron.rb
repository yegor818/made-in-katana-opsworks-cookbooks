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

  # Remove any old crons beginning with the filename. As the removed crons
  # cannot be detected, it is easier to remove them all and create them again.
  execute "delete old crons" do
    command "rm -f #{node[:setup][:cron][:cron_dir]}/#{filename}-*"
  end

  # Send a reload signal to the crond service to read any new configurations.
  # This is not always required, but it is good practice to do it.
  service "crond" do
    action :reload
  end

end
