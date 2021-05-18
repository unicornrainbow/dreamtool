ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'

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

class TestReporter < Minitest::Reporters::DefaultReporter

  def cupcake
    "\u{1F9C1}"
  end

  def glassofmilk
    "\u{1F95B}"
  end

  def flower;"\u{1F338}" end
  def tulip ; "\u{1F337}" end

  def green(string)
    if string == "."
      [cupcake, glassofmilk].sample
    else
      string
    end
  end

end
Minitest::Reporters.use! [TestReporter.new]
