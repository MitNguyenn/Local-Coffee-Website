require "require_all"
require "sinatra"
require "sinatra/reloader"

require_all "controllers"
require_relative "helpers/helpers"
require_relative "db/db"
require_relative "db/databaseHelper"
require_all "models"
enable :sessions

require_relative 'controllers/routes'

#Database
require_all "models/account.rb"
require_all "models/bean.rb"
require_all "models/order.rb"
require_all "models/ticket.rb"
require "db/db.rb"
