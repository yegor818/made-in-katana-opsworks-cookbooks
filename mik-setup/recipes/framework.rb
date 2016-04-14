# Setup any shared libraries needed for applications in this recpie. They should
# simply be deployed from a Git repository to a local target on the disk.
if node[:setup][:framework][:yii][:repository].length > 0

  # Deploy the Yii framework via the Git repository provided.
  git node[:setup][:framework][:yii][:path] do
    repository node[:setup][:framework][:yii][:repository]
    branch node[:setup][:framework][:yii][:revision]
    action :sync
  end

else

  # Log an info message if the settings were not provided correctly.
  log "message" do
    message "MIK-SETUP: Unable to deploy Yii framework as no Git repository has been provided."
    level :info
  end

end

# Install Composer which is required for dependency management in Laravel. While
# this is not required, it will not be available as a system binary if it is
# not installed.
execute "install composer" do
  command "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin && mv -f /usr/bin/composer.phar /usr/bin/composer"
end

# Schedule the Composer self-updater to run every day. If Composer is not
# automatically updated after 30 days, it will refuse to install until it is
# updated. If this fails, running mik-setup::framework will reinstall it.
cron "schedule composer self-updater" do
  minute "0"
  hour "2"
  day "*"
  month "*"
  weekday "*"
  command "/usr/bin/composer self-update > /dev/null 2>&1"
  action :create
end
