# If the default recipe is ran, then simply return a fatal error. Due to the
# dynamic configuration of this environment with different nodes performing
# different tasks, the required recipes should be manually specified when the
# appropriate command is called.
log "message" do
  message "MIK-SETUP: This cookbook has a modular configuration. Please refer to the documentation for correct usage."
  level :fatal
end
