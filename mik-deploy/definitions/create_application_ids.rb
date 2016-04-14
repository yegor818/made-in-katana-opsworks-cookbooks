define :create_application_ids do

  # Assign variable names to the parameters passed.
  application = params[:application_name]

  # Set the fail flag to zero.
  node.default[:deploy][application][:fail] = 0

  # If a user and group ID has been specified in the JSON string for the
  # application, then create them both.
  if node[:deploy][application][:id]

    directory node[:deploy][application][:home_dir] do
      owner "root"
      group "root"
      mode 0777
      recursive true
      action :create
    end

    group "#{node[:deploy][application][:group_name]}" do
      gid node[:deploy][application][:id]
      only_if { `cat /etc/group | grep -E '^#{node[:deploy][application][:group_name]}:'` }
    end

    user "#{node[:deploy][application][:user_name]}" do
      uid node[:deploy][application][:id]
      gid node[:deploy][application][:id]
      home "#{node[:deploy][application][:home_dir]}"
      shell "/sbin/nologin"
      only_if { `cat /etc/passwd | grep -E '^#{node[:deploy][application][:user_name]}:'` }
    end

    # Create any standard directories for the user.
    create_application_dirs do
      application_name application
    end

  else

	Chef::Log.info "MIK: #{node[:deploy][application]}"
    # Since this failed, set the fail flag to 1.
    node.default[:deploy][application][:fail] = 1

    log "message" do
      message "MIK-DEPLOY: Cannot deploy application without unique user and group ID."
      level :fatal
    end

  end

end
