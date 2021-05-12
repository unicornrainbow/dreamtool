ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include Mongoid::FixtureSet::TestHelper
  self.fixture_path = "#{Rails.root}/test/fixtures"

  # ActiveRecord::Migration.check_pending!

  # Clear out the test database before every run.
  Mongoid.purge! if Rails.env.test?

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
