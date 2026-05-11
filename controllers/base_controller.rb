class BaseController < Sinatra::Base
  helpers AppHelpers
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] 

  require 'bcrypt'
  require 'require_all' 

  require_relative '../db/db'

  set :root, File.expand_path("..", __dir__)
  set :views, proc { File.join(root, "views") }
  set :public_folder, proc { File.join(root, "public") }

  before do
    if session[:UserID] && !session[:UserID]
      session[:UserID] = session[:UserID]
    elsif session[:UserID] && !session[:UserID]
      session[:UserID] = session[:UserID]
    end
  end

  get '/' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    
    erb :home
  end

  get '/help' do
    erb :help
  end

  post '/help' do
    userid = DB[:Accounts].where(email: params[:form_useremail]).get(:UserID)
    
    if userid.nil? || params[:form_request_description].to_s.strip.empty?
      @error = "Missing info! Please check the email and description."
      return erb :help
    end

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
end