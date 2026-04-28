class BaseController < Sinatra::Base
  enable :sessions
  set :session_secret, "your_secure_random_string_here"

  # 2. Required Gems
  require 'bcrypt'
  require 'require_all' # Ensure this gem is installed


  require_relative '../db/db'

  require_all File.join(File.dirname(__FILE__), '..', 'helpers')

end
