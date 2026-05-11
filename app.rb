require "dotenv/load"
require "require_all"
require "sinatra/base"
require "rqrcode"

require_relative "db/db"
require_all "models"
require_all "helpers"
require_all "controllers"

class CoffeeApp < Sinatra::Base
  helpers AppHelpers
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  
  set :root, File.dirname(__FILE__)
  set :views, proc { File.join(root, "views") }
  set :public_folder, proc { File.join(root, "public") }

  use AuthController
  use ProductController
  use AccountController
  use AdminController
  use BaristaController
  use ManagerController

  run! if app_file == $0
end
