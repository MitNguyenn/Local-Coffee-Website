# Start Coverage
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/app.rb"
  add_filter "/db/db.rb"
  add_filter "/helpers/helpers.rb"
end

# Establish DB Connection
require 'sequel'
DB = Sequel.connect("sqlite://db/db.sqlite3") 

# Load helpers
require_relative "../helpers/validation"
require_relative "../helpers/passwordCheck"
require_relative "../helpers/analyzeData"
require_relative "../helpers/myOrders"
require_relative "../helpers/accountRecency"

# Load specific test functions (including spec_before)
require_relative "spec_functions"

# Load the App
ENV["APP_ENV"] = "test"
require_relative "../app"

# Configure Capybara and RSpec
require "capybara/rspec"

Capybara.app = CoffeeApp
Capybara.configure do |config|
  config.ignore_hidden_elements = false 
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods

  # 1. This runs EXACTLY ONCE at the very start to build/seed the DB
  config.before(:suite) do
    spec_before 
  end

  # 2. Manual Transaction Management
  # Wraps every test in a transaction that always rolls back
  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end
end
