require "require_all"
require "sinatra"
require "sinatra/reloader"

require_all "controllers"
require_relative "helpers/helpers"
require_relative "db/db"
require_relative "db/databaseHelper"
require_all "models"
enable :sessions

require_relative 'controllers/routes'

# Initialize database tables on startup
configure do
  DatabaseHelper.init_account_table
  DatabaseHelper.init_bean_table
end
end