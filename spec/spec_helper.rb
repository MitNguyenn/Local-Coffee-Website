# Start Coverage
require "simplecov"
SimpleCov.start do # Exclude test files and non-app code from coverage
  add_filter "/spec/"
  add_filter "/app.rb"
  add_filter "/db/db.rb"
  add_filter "/helpers/helpers.rb"
end

#Establish DB Connection
require 'sequel'
DB = Sequel.connect("sqlite://db/db.sqlite3") 

#load helpers

require_relative "../helpers/validation"
require_relative "../helpers/passwordCheck"
require_relative "../helpers/analyzeData"
require_relative "../helpers/myOrders"
require_relative "../helpers/accountRecency"

#Now load the App (which loads the models)
ENV["APP_ENV"] = "test"
require_relative "../app"

#Configure Capybara and RSpec
require "capybara/rspec"
Capybara.app = Sinatra::Application

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods

  config.before do
    spec_before
  end
end

require_relative "spec_functions"
