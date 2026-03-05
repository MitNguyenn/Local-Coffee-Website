require "require_all"
require "sinatra"
require "rqrcode"

require_all "controllers"
require_relative "helpers/helpers"
require_all "models"
enable :sessions

require_relative 'controllers/routes'

require "helpers/helpers.rb"
#Database + models

require_all "models/account.rb"
require_all "models/bean.rb"
require_all "models/order.rb"
require_all "models/ticket.rb"
require "db/db.rb"
