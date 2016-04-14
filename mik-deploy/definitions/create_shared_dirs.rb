# Create a definition for when the CMS is deployed.
define :create_shared_dirs do
  Chef::Log.info "MIK: create_shared_dirs.rb"
  
  # Assign variable names to the parameters passed.
  application = params[:application_name]
  release_path = params[:release_path]

  # If the CMS flag is set to true, then do everything that is needed to get it
  # up and running without any manual intervention.
  if node[:deploy][application][:shared]

	Chef::Log.info "MIK: Shared dir is available"
    node[:deploy][application][:shared].each do |dir|

      directory "#{node[:setup][:nfs][:target]}/#{node[:deploy][application][:document_root]}/#{dir}" do
        owner "root"
        group "root"
        mode 0777
        recursive true
        action :create
        not_if { File.exist?("#{node[:setup][:nfs][:target]}/#{node[:deploy][application][:document_root]}/#{dir}") }
      end

	  Chef::Log.info "MIK: granting full permission to the shared dir"
	  
      execute "copy existing files" do
        command "rsync -av --remove-source-files #{release_path}#{node[:deploy][application][:code_path]}/#{dir}/ #{node[:setup][:nfs][:target]}/#{node[:deploy][application][:document_root]}/#{dir}"
        only_if { File.exist?("#{release_path}#{node[:deploy][application][:code_path]}/#{dir}") }
      end

      directory "#{release_path}#{node[:deploy][application][:code_path]}/#{dir}" do
        recursive true
        action :delete
        only_if { File.exist?("#{release_path}#{node[:deploy][application][:code_path]}/#{dir}") }
      end 

      link "#{release_path}#{node[:deploy][application][:code_path]}/#{dir}" do
        to "#{node[:setup][:nfs][:target]}/#{node[:deploy][application][:document_root]}/#{dir}"
      end

	   # Change permission to the shared directory in the application home directory.
      Chef::Log.info "chmod: -777 =#{node[:setup][:nfs][:target]}/#{node[:deploy][application][:document_root]}/#{dir}"
      #command "chmod -R 777 #{node[:setup][:nfs][:target]}/#{node[:deploy][application][:document_root]}/#{dir}"

    end
  end
end
