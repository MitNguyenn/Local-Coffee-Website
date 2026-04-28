class BaseController < Sinatra::Base
  enable :sessions

  require 'bcrypt'
  require_relative '../db/db'
  require_relative '../helpers
  
  helpers Sinatra::Helpers 
end
