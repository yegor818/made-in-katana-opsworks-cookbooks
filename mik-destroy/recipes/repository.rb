# Iterate through the applications passed by OpsWorks.
node[:deploy].each do |application, deploy|

  # If the application was not in the JSON string passed by OpsWorks, then it
  # should not be modified in any way.
  if !deploy[:application]
    next
  end

  # Delete the document root from the system recursively.
  directory "#{node[:setup][:nginx][:www_dir]}/#{deploy[:document_root]}" do
    recursive true
    action :delete
  end

end
