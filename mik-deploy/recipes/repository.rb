# Iterate through the applications passed by OpsWorks.
node[:deploy].each do |application, deploy|

  Chef::Log.info "MIK: repository.rb" 
    
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

  # Determine which repository is being used to download the code to the
  # application servers.
  case node[:deploy][application][:scm][:scm_type]
  when "git"

    # If an SSH key has been supplied, then it needs to be saved on the instance
    # and used with an SSH wrapper
    if node[:deploy][application][:scm][:ssh_key]

      directory "/tmp/.ssh" do
        action :create
        not_if { File.exist?("/tmp/.ssh") }
      end

      template "/tmp/.ssh/ssh_deploy_wrapper.sh" do
        source "ssh_deploy_wrapper.sh.erb"
        owner "root"
        mode 0770
      end

      file "/root/.ssh/id_deploy" do
      	Chef::Log.info "MIK-mansi: #{node[:deploy][application][:scm][:ssh_key]}"
        content node[:deploy][application][:scm][:ssh_key]
        owner "root"
        group "root"
        mode 0600
      end

    end

    # If a repository has been provided, then clone it using the built-in
    # versioning system. If it has not been provided, then that is quite useless
    # for a Git deployment.
    if node[:deploy][application][:scm][:repository]

	  Chef::Log.info "MIK-repository: #{node[:setup][:nginx][:www_dir]}"
	  Chef::Log.info "MIK-repository: #{deploy[:document_root]}"
	  
      deploy "#{node[:setup][:nginx][:www_dir]}/#{deploy[:document_root]}" do
        repository node[:deploy][application][:scm][:repository]
        branch node[:deploy][application][:scm][:revision]
        git_ssh_wrapper "/tmp/.ssh/ssh_deploy_wrapper.sh"
        shallow_clone false
        keep_releases 1
        symlink_before_migrate.clear
        create_dirs_before_symlink.clear
        purge_before_symlink.clear
        symlinks.clear
        migrate false
        enable_submodules true
        action :deploy

        # When the repository has been deployed, do the following using the
        # variables provided by the deploy definition.
        before_symlink do

          # The release_path is only a local variable and cannot be passed to
          # the yii definition - maybe a bug? To fix this, simply create another
          # variable to hold the string.
          app_release_path = release_path

          # Check to see if Laravel is in the repository and create the template
          # files for the configuration.
          laravel do
            application_name application
            release_path app_release_path
          end

          # Trigger the Yii symlinking.
          yii do
            application_name application
            release_path app_release_path
          end

          create_shared_dirs do
            application_name application
            release_path app_release_path
          end

          # Run the process to check if a deploy script needs to be run or not.
          # This may be required for some web applications like Laravel.
          run_deploy_script do
            application_name application
            release_path app_release_path
          end

          # Run the process to check if a deploy script needs to be run or not.
          # This may be required for some web applications like Laravel.
          run_deploy_script do
            application_name application
            release_path app_release_path
          end

          # Trigger the permission change for any writeable directories.
          writable do
            deploy_data node[:deploy][application]
            release_path app_release_path
          end

        end

      end

    end

  else

    # By default, create an empty current directory for applications that do not
    # have a code repository.
    directory "#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:current_path]}" do
      owner "root"
      group "root"
      mode 0755
      recursive true
      action :create
    end

    # If some other repository has been specified, then notify the administrator
    # that it is not supported by this recipe.
    log "message" do
      message "Sorry, the repository type you have provided is not supported."
      level :info
    end

  end

  # If the SSH key exists on the system, remove it for security purposes.
  if File.exists?("/root/.ssh/id_deploy")
    file "/root/.ssh/id_deploy" do
      action :delete
    end
  end

  # Iterate through any symlink requests in the location block object. This will
  # create a symlink for any applications that need to be accessible under its
  # own domain name and a shared domain name.
  # should create files and folders that don't exist. -Si 28/04/2014
  if node[:deploy][application][:nginx][:location]

    log "message" do
      message "MIK-DEPLOY: attempting symlink"
      level :info
    end

    node[:deploy][application][:nginx][:location].each do |path, location|
      if location[:symlink]
        log "message" do
          message "MIK-DEPLOY: attempting symlink"
          level :info
        end
        
        mydir = File.dirname("#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:document_root]}/#{path}")
            
        unless File.directory?(mydir)
            log "message" do
              message "MIK-DEPLOY: no dir found. creating"
              level :info
            end
            directory mydir do
                owner node[:deploy][application][:user_name]
                group node[:deploy][application][:group_name]
                mode 0771
                recursive true
                action :create
            end
        end
        
        link "#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:document_root]}/#{path}" do
          to "#{node[:setup][:nginx][:www_dir]}/#{location[:symlink]}/current#{node[:deploy][application][:code_path]}"
        end
        
      end
    end

  end

  # Deploy any other custom template files specified in the JSON string from
  # OpsWorks. This allows any application to have its own templates using the
  # deployment variables.
  if node[:deploy][application][:template]

    node[:deploy][application][:template].each do |template, id|
      template "#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:current_path]}/#{id[:destination]}" do
        local true
        source "#{node[:setup][:nginx][:www_dir]}/#{node[:deploy][application][:current_path]}/#{id[:source]}"
        owner "root"
        group "root"
        mode 0644
        variables (:application => node[:deploy][application])
      end
    end

  end

  # Fix the permissions for any modified files.
  fix_application_perms do
    application_name application
  end

end
