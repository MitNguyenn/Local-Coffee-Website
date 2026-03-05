require 'sinatra'
require 'sinatra/reloader' if development?
require "bcrypt"

enable :sessions
require_relative '../db/db.rb'
require_relative '../db/databaseHelper'
require_relative '../models/userAccount.rb'
get '/' do
  erb :home
end

get '/coffee-beans' do
    @beans = DB[:beans].all
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
  user = UserObject.first(email: params[:email]) # Finder

  # Data Processed
  if user && BCrypt::Password.new(user.password_hash) == params[:password1]
    session[:user_id] = user.id
    # GOTO
    redirect '/'
  else
    @error = "Invalid credentials"
    erb :login_screen
  end
end

get "/account-settings" do
  #use this once database working
  #redirect "/log-in" unless current_user

    #user = current_user
    # need to figure out how to pull data from database
    # hard coded temp data
    @first_name = "First" #user.first_name
    @last_name = "Last" #user.last_name
    @date_of_birth = "01/01/01" #user.date_of_birth
    @phone = "+44 07000 000000" #user.phone
    @email = "test@gmail.com" #user.email
    @password = "password" #user.password_hash 
    @postcode = "S10 3AB" #user.postcode
    # address number/house name could be stored seperately
    @address = "1 Endcliffe Cresent" #user.address

get '/register' do
  erb :register_account
end

post '/register' do
  # Use validation helpers to validate input
  email = params[:email]
  password = params[:password]
  first_name = params[:first_name]
  last_name = params[:last_name]
  phone = params[:phone]
  address = params[:address]

  # Validate email format
  unless str_email_address?(email)
    @error = "Invalid email format"
    return erb :register_account
  end

  # Validate phone number
  unless str_uk_telephone?(phone)
    @error = "Invalid UK phone number"
    return erb :register_account
  end

  # Validate password length
  unless str_min_length?(password, 8)
    @error = "Password must be at least 8 characters"
    return erb :register_account
  end

  # Create new user account
  user = UserObject.create(
    first_name: first_name,
    last_name: last_name,
    email: email,
    password_hash: BCrypt::Password.create(password).to_s,
    phone: phone,
    address: address,
    account_type: "customer"
  )

  session[:user_id] = user.id
  redirect '/'
rescue => e
  @error = "Registration failed: #{e.message}"
  erb :register_account
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

get '/change-password' do
  erb :change_password
end

post '/change-password' do
  password1 = params[:password1]
  password2 = params[:password2]
  if password1 == password2
    redirect '/account-settings'
    # Here you would also want to update the user's password in the database
  else
    @error = "Passwords do not match"
    return erb :change_password
  end
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
