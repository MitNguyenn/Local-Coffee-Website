require "require_all"
require "sinatra"
require "rqrcode"

require_all "controllers"
# require_relative "helpers/helpers"
require_all "models"
enable :sessions

require_relative 'controllers/routes'
include "helpers/helpers.rb"