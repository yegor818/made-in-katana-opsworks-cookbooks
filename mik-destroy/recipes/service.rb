# Define the nginx service with its allowed parameters.
service "nginx" do
  supports :status => true, :restart => true, :reload => true
end

# Define the php-fpm service with its allowed parameters.
service "php-fpm" do
  supports :status => true, :restart => true, :reload => true
end

# Define the crond service with its allowed parameters.
service "crond" do
  supports :status => true, :restart => true, :reload => true
end
