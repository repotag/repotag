# Load the rails application
require File.expand_path('../application', __FILE__)

config_location = java.lang.System.getProperty('config') || ::File.join(java.lang.System.getProperty("user.dir"), 'repotag.yml')

REPOTAG_CONFIG = YAML.load_file(config_location)

# Initialize the rails application
Repotag::Application.initialize!

