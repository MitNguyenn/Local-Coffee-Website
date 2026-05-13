# Start Coverage
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/app.rb"
  add_filter "/db/db.rb"
  add_filter "/helpers/helpers.rb"
end

# Establish test suite connection using an absolute path definition pattern
require 'sequel'
db_absolute_path = File.expand_path("../../db/db.sqlite3", __FILE__)
DB = Sequel.sqlite(db_absolute_path)

# Load database initializer script 
require_relative "../db/DB_init"

# Load application architectural functional helpers
require_relative "../helpers/validation"
require_relative "../helpers/passwordCheck"
require_relative "../helpers/analyzeData"
require_relative "../helpers/myOrders"
require_relative "../helpers/accountRecency"

# Load specific test functions definitions profile wrapper
require_relative "spec_functions"

ENV["APP_ENV"] = "test"
require_relative "../app"

require "capybara/rspec"
Capybara.app = CoffeeApp
Capybara.configure do |config|
  config.ignore_hidden_elements = false 
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods

  # This runs EXACTLY ONCE at the start to clean tables and insert baseline seeds
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