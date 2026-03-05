require "require_all"
require "sinatra"
require "rqrcode"

require_all "controllers"
require_relative "helpers/helpers"
require_all "models"
enable :sessions

require_relative 'controllers/routes'

# Initialize database tables on startup
# configure do
#   DatabaseHelper.init_account_table
#   DatabaseHelper.init_bean_table
# end
