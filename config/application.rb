require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module CoworkingBooking
  class Application < Rails::Application
    config.load_defaults 7.0
    config.generators.system_tests = nil
    config.time_zone = "Moscow"
  end
end