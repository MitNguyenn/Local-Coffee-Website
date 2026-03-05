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
require_all "models/beanObject.rb"
require_all "models/userAccount.rb"
require "db/db.rb"
