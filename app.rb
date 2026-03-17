require "dotenv/load"
require "require_all"
require "sinatra"
require "rqrcode"

enable :sessions
set :session_secret, ENV['SESSION_SECRET']

require_all "controllers"
require_relative "helpers/helpers"
require_all "models"

require_relative 'controllers/routes'

# Initialize database tables on startup
# configure do
#   DatabaseHelper.init_account_table
#   DatabaseHelper.init_bean_table
# end

