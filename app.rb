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

  # 4. Main Routes
  get '/' do
    erb :home
  end

  get '/help' do
    erb :help
  end

  post '/help' do
    # Find the user by email
    userid = DB[:Accounts].where(email: params[:form_useremail]).get(:UserID)
    
    # Validation
    if userid.nil? || params[:form_request_description].to_s.strip.empty?
      @error = "Missing info! Please check the email and description."
      return erb :help
    end

    # Create the ticket using your Model logic
    begin
      Ticket.create(
        UserID: userid, 
        ticketType: params[:problem_type], 
        ticketContent: params[:form_request_description]
      )
      redirect "/"
    rescue => e
      @error = "Something went wrong: #{e.message}"
      erb :help
    end
  end

  # 5. Start the server if this file is executed directly
  run! if app_file == $0
end
