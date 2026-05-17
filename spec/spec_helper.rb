# Start Coverage
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/app.rb"
  add_filter "/db/db.rb"
  add_filter "/helpers/helpers.rb"

  # db init files
  add_filter "db/DB_init"
  add_filter "db_setup"
  add_filter "db_seeder"
end

# Establish test suite connection using an absolute path definition pattern
require 'sequel'
db_absolute_path = File.expand_path("../../db/db.sqlite3", __FILE__)

# Check if DB is already assigned globally to prevent runtime collision warnings
unless defined?(DB)
  DB = Sequel.sqlite(db_absolute_path)
end

# Load database initializer script 
require_relative "../db/DB_init"

# Load application architectural functional helpers
require_relative "../helpers/validation"
require_relative "../helpers/passwordCheck"
require_relative "../helpers/analyzeData"
require_relative "../helpers/myOrders"
require_relative "../helpers/accountRecency"

require_relative "spec_functions"

ENV["APP_ENV"] = "test"

require_relative "../app"

require "capybara/rspec"
require "rack/test"

require 'sinatra'
Capybara.app = Sinatra::Application

Capybara.configure do |config|
  config.ignore_hidden_elements = false 
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  config.before(:suite) do
    spec_before 
  end

  # Manual Transaction rollback manager
  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end
end