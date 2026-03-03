require 'sinatra'
require 'sinatra/reloader' if development?
require "bcrypt"
require_relative '../db/db.rb'
require_relative '../models/userObject.rb'
require_relative '../models/beanObject.rb'

get '/' do
  erb :home
end

get '/coffee-beans' do
  erb :beans
end

get '/help' do
  erb :help
end

get '/staff-portal' do
  erb :staffportal
end

get '/log-in' do
  @email = ""
  @password1 = ""
  @password2 = ""
  erb :login_screen
end

post '/login' do
  user = UserObject.first(email: params[:email]) # Finder method

  # Data Processed
  if user && BCrypt::Password.new(user.password_hash) == params[:password1]
    session[:user_id] = user.id
    # GOTO
    redirect '/'
  else
    @error = "Invalid credentials"
    erb :login_screen
  end

get '/register' do
  erb :register_account
end

post '/register' do
  "do something lmao"
end

get '/account-settings' do
  @first_name = "First"
  @last_name = "Last"
  @dob = "01/01/01"
  @phone = "+44 07000 000000"
  @email = "test@gmail.com"
  @password = "password"
  @postcode = "S10 3AB"
  @address = "1 Endcliffe Cresent"
  erb :account_settings
end

get '/loyalty-card' do 
  erb :loyalty_card
end

get '/my-orders' do
  erb :my_orders
end

get '/log-out' do
  session.clear  
  redirect '/'
end

get '/forgot' do
  erb :forgot_password
end