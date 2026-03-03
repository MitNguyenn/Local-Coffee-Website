require "require_all"
require "sinatra"

require_all "controllers"
require_relative "helpers/helpers"
require_relative "db/db"
require_all "models"
require_all "db/databaseFuctions.rb"
enable :sessions

require_relative 'controllers/routes'

# Initialize database tables on startup
init_account_table
init_bean_table
