require "require_all"
require "sinatra"
require "rqrcode"

require_all "controllers"
# require_relative "helpers/helpers"
require_all "models"
enable :sessions

<<<<<<< HEAD
require_relative 'controllers/routes'

# Initialize database tables on startup
# configure do
#   DatabaseHelper.init_account_table
#   DatabaseHelper.init_bean_table
# end
=======
require_relative 'controllers/routes'
>>>>>>> aa3f1ca66e212634a40c3342184e537d18e40b5c
