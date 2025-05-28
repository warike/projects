# Load the Rails application.
require File.expand_path('../application', __FILE__)

APP_CONFIG = HashWithIndifferentAccess.new
load_files = Dir["#{Rails.root}/config/app_config/*.yml"].each do |file|
  APP_CONFIG.merge!(YAML.load_file(file)[Rails.env])
end

APP_CONFIG['es_url_website'] = 'localhost:3000/?locale=es'

# Initialize the Rails application.
Rails.application.initialize!

