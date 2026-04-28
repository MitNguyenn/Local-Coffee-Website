class BaseController < Sinatra::Base
  helpers AppHelpers
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] 

  # 2. Required Gems
  require 'bcrypt'
  require 'require_all' # 

  require_relative '../db/db'

  set :root, File.expand_path("..", __dir__)
  set :views, proc { File.join(root, "views") }
  set :public_folder, proc { File.join(root, "public") }

end