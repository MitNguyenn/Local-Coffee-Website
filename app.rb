require "dotenv/load"
require "require_all"
require "sinatra"
require "rqrcode"

enable :sessions
set :session_secret, ENV['SESSION_SECRET']

require_all "controllers"
require_relative "helpers/helpers"
require_all "models"



#Base Routes
class CoffeeApp < Sinatra::Base
  use AuthController
  use ProductController
  use AccountController
  use AdminController

  get '/' do
    erb :home
  end

  get '/help' do
    erb :help
  end

  post '/help' do
    userid = DB[:Accounts].where(email: params[:form_useremail]).get(:UserID)
    if userid.nil? || params[:form_request_description].empty?
      @error = "Missing info!"
      return erb :help
    end
    Ticket.create(UserID: userid, ticketType: params[:problem_type], ticketContent: params[:form_request_description])
    redirect "/"
  end

  run! if app_file == $0
end