# Iterate through the applications passed by OpsWorks.
node[:deploy].each do |application, deploy|

  # If the application was not in the JSON string passed by OpsWorks, then it
  # should not be modified in any way.
  if !deploy[:application]
    next
  end

  # Delete the application user from the system.
  user "#{deploy[:user_name]}" do
    action :remove
  end

  # Delete the application group from the system.
  group "#{deploy[:group_name]}" do
    action :remove
  end

end
