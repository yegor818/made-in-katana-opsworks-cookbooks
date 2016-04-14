# Execute a command to force a new symlink on the /etc/localtime file. This
# will set the timezone for the server.
execute "set timezone" do
  command "ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime"
end
