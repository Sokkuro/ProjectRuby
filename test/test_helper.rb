ENV["RAILS_ENV"] ||= "test"

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/config/'
end

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Parallel tests can race on Sprockets cache on Windows.
    parallelize(workers: 1)

    fixtures :all
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
