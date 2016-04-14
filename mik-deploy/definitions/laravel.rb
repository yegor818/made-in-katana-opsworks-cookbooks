define :laravel do

  # Create variables based on parameters passed.
  application  = params[:application_name]
  release_path = params[:release_path]

  # Create the app.php file for Laravel based on the template if it exists. If
  # it does not exist, then it will just skip it.
  template "#{release_path}#{node[:deploy][application][:code_path]}/app/config/app.php" do
    local true
    source "#{release_path}#{node[:deploy][application][:code_path]}/app/config/app.erb"
    owner "root"
    group "root"
    mode 0644
    variables (:application => node[:deploy][application])
    only_if { File.exists?("#{release_path}#{node[:deploy][application][:code_path]}/app/config/app.erb") }
  end

  # Create the database.php file for Laravel based on the template if it exists.
  # If it does not exist, then it will just skip it.
  template "#{release_path}#{node[:deploy][application][:code_path]}/app/config/database.php" do
    local true
    source "#{release_path}#{node[:deploy][application][:code_path]}/app/config/database.erb"
    owner "root"
    group "root"
    mode 0644
    variables (:application => node[:deploy][application])
    only_if { File.exists?("#{release_path}#{node[:deploy][application][:code_path]}/app/config/database.erb") }
  end

end
