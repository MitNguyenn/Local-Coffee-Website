require "require_all"
require "sinatra"
require "sinatra/reloader"

require_all "controllers"
require_relative "helpers/helpers"
require_relative "db/db"
require_all "models"
require_all "db/databaseFuctions.rb"
enable :sessions

require_relative 'controllers/routes'

# Initialize database tables on startup
# configure do
#   DatabaseHelper.init_account_table
#   DatabaseHelper.init_bean_table
# end
