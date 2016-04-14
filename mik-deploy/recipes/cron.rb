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

  # Remove any old crons beginning with the filename. As the removed crons
  # cannot be detected, it is easier to remove them all and create them again.
  execute "delete old crons" do
    command "rm -f #{node[:setup][:cron][:cron_dir]}/#{filename}-*"
  end

  # If any crons have been specified in the JSON string, then iterate through
  # them and create the cron file based on the ERB template provided. Each cron
  # must be given a unique name, so each cron will be in its own file for
  # administration purposes.
  if deploy[:cron]
    deploy[:cron].each do |cron, id|
      template "#{node[:setup][:cron][:cron_dir]}/#{filename}-#{cron}" do
        source "cron.erb"
        owner "root"
        group "root"
        mode 0644
        variables (:cron => id, :user => node[:deploy][application][:user_name])
      end
    end
  end

  # Fix the permissions for any modified files.
  fix_application_perms do
    application_name application
  end

  # Send a reload signal to the crond service to read any new configurations.
  # This is not always required, but it is good practice to do it.
  service "crond" do
    action :reload
  end

end
