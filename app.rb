require "dotenv/load"
require "require_all"
require "sinatra/base"
require "rqrcode"

# 1. Load Data and logic dependencies
require_relative "db/db"
require_all "models"
require_all "helpers"
require_all "controllers"

class CoffeeApp < Sinatra::Base
  helpers AppHelpers
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  
  # Ensure Sinatra knows where your folders are
  set :root, File.dirname(__FILE__)
  set :views, proc { File.join(root, "views") }
  set :public_folder, proc { File.join(root, "public") }

  # 3. Middleware Controllers
  # These will be checked for routes BEFORE the routes below
  use AuthController
  use ProductController
  use AccountController
  use AdminController
  use BaristaController
  use ManagerController

  # 5. Start the server if this file is executed directly
  run! if app_file == $0
end
