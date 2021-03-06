require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Renupharm
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Use a real queuing backend for Active Job (and separate queues per environment)
    config.active_job.queue_adapter     = :sidekiq
    config.send_sms                     = false

    # Define an asset host, allowing us to build full URLs
    config.action_controller.asset_host = 'http://localhost:3000'

    # Set timezone to Dublin
    config.time_zone = "Dublin"
  end
end
