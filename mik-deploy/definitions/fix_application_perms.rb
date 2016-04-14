
define :fix_application_perms do
  
  Chef::Log.info "MIK: fix_application_perms.rb" 
  
  # Assign variable names to the parameters passed.
  application = params[:application_name]

  # Reset the ownership of the application home directory.
  execute "reset ownership of application home directory" do
    command "chown #{node[:deploy][application][:user_name]}:#{node[:deploy][application][:group_name]} #{node[:deploy][application][:home_dir]}"
  end

  # Reset the ownership of the current directory
  execute "reset current directory" do
    command "chown -Rf #{node[:deploy][application][:user_name]}:#{node[:deploy][application][:group_name]} #{node[:deploy][application][:home_dir]}/current"
    only_if { File.exist?("#{node[:deploy][application][:home_dir]}/current") }
  end

  # Reset the ownership of the logs directory.
  execute "reset current directory" do
    command "chown -Rf #{node[:deploy][application][:user_name]}:#{node[:deploy][application][:group_name]} #{node[:deploy][application][:home_dir]}/logs"
    only_if { File.exist?("#{node[:deploy][application][:home_dir]}/logs") }
  end

  # Reset the ownership of the releases directory.
  execute "reset current directory" do
    command "chown -Rf #{node[:deploy][application][:user_name]}:#{node[:deploy][application][:group_name]} #{node[:deploy][application][:home_dir]}/releases"
    only_if { File.exist?("#{node[:deploy][application][:home_dir]}/releases") }
  end

# Reset the ownership of the sessions directory.
  execute "reset current directory" do
    command "chown -Rf #{node[:deploy][application][:user_name]}:#{node[:deploy][application][:group_name]} #{node[:deploy][application][:home_dir]}/sessions"
    only_if { File.exist?("#{node[:deploy][application][:home_dir]}/sessions") }
  end

  # Reset the ownership of the shared directory.
  execute "reset current directory" do
    command "chown -Rf #{node[:deploy][application][:user_name]}:#{node[:deploy][application][:group_name]} #{node[:deploy][application][:home_dir]}/shared"
    only_if { File.exist?("#{node[:deploy][application][:home_dir]}/shared") }
  end
  
 # Reset permissions of the application files.
  execute "reset permissions of application files" do
    command "find #{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:current_path]} -type f -exec chmod 0664 {} \\;"
    only_if { File.exist?("#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:current_path]}") }
  end

  # Reset permissions of the directories in the application home directory.
  execute "reset permissions of application files" do
    command "find #{node[:deploy][application][:home_dir]} -type d -exec chmod 0775 {} \\;"
  end

  # Reset the permissions of the application home directory.
  execute "reset permissions of application home directory" do
    command "chmod 0771 #{node[:deploy][application][:home_dir]}"
  end

end
