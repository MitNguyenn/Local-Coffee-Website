require 'sinatra'
require "bcrypt"
require_relative '../db/db.rb'

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

get '/register' do
  erb :register_account
end

post '/register' do
  email = params[:email]
  password = params[:password]
  first_name = params[:first_name]
  last_name = params[:last_name]
  phone = params[:phone]
  address = params[:address]

  unless str_email_address?(email)
    @error = "Invalid email format"
    return erb :register_account
  end

  unless str_uk_telephone?(phone)
    @error = "Invalid UK phone number"
    return erb :register_account
  end

  unless str_min_length?(password, 8)
    @error = "Password must be at least 8 characters"
    return erb :register_account
  end

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
  redirect '/login' unless session[:user_id]

  user = DB[:Accounts].where(UserID: session[:user_id]).first

  @first_name = user[:First_Name]
  @last_name  = user[:Last_name]
  @email      = user[:email]
  @address    = user[:Postal_address]
  @postcode   = user[:Phone_number] 

  erb :account_settings
end

post '/update-account' do
  redirect '/log-in' unless session[:user_id]

  DB[:Accounts].where(UserID: session[:user_id]).update(
    First_Name:     params[:First_Name],
    Last_name:      params[:Last_name],
    Postal_address: params[:Postal_address]
  )

  redirect '/account-settings'
end

get '/change-password' do
  erb :change_password
end

post '/change-password' do
  password1 = params[:password1]
  password2 = params[:password2]
  if password1 == password2
    redirect '/account-settings'
  else
    @error = "Passwords do not match"
    return erb :change_password
  end
end

get '/loyalty-card' do
  # redirect '/login' unless session[:user_id]

  # @user = DB[:users].where(id: session[:user_id]).first

  # qrcode = RQRCode::QRCode.new("user_id:#{@user[:id]}")

  qr_content = "TEST-USER-12345"

  qrcode = RQRCode::QRCode.new(qr_content)
  @qr_svg = qrcode.as_svg(
    color: "4b2c20", 
    shape_rendering: "crispEdges",
    module_size: 6,
    standalone: true,
    use_path: true,
    viewbox: true
  )

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