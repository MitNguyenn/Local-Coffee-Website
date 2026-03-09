require 'sinatra'
require 'bcrypt'
require_relative '../db/db.rb'
require_relative '../helpers/helpers'

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
  @password = ""
  erb :login_screen
end

post '/log-in' do
  @email = params[:email]
  @password = params[:password]

  puts @password

  user = DB[:accounts].where(email: @email).first
  
  if user && BCrypt::Password.new(user[:hashedPassword]) == @password then
    session[:user_id] = user[:UserID]
    puts "Login successful for email: #{@email}"
    redirect '/'
  else
    @error = "Invalid email or password"
    erb :login_screen
  end
end

get '/register' do
  erb :register_account
end

post '/register' do
  # Use validation helpers to validate input
  email = params[:email]
  password1 = params[:password1]
  password2 = params[:password2]
  first_name = params[:first_name]
  last_name = params[:last_name]
  phone_number = params[:phone_number]
  postcode = params[:postcode]

  UserID = nil
  loop do
    UserID = rand(10000000..99999999)
    break unless Account[UserID]
  end

  # Validate email format
  unless str_email_address?(email)
    @error = "Invalid email format"
    return erb :register_account
  end

  # Validate phone number
  unless str_uk_telephone?(phone_number)
    @error = "Invalid UK phone number"
    return erb :register_account
  end

  # Check passwords match
  unless password1 == password2
    @error = "Passwords don't match"
    return erb :register_account
  end

  # Validate password length
  unless str_min_length?(password1, 8)
    @error = "Password must be at least 8 characters"
    return erb :register_account
  end


  # Create new user account
  user = Account.create(
    UserID: UserID,
    First_Name: first_name,
    Last_name: last_name,
    email: email,
    #password_hash: BCrypt::Password.create(password).to_s,
    password: password1,
    Phone_number: phone_number,
    Postal_address: postcode,
    :"Account_type" => "customer"
  )

  session[:user_id] = user.UserID
  redirect '/'
rescue => e
  @error = "Registration failed: #{e.message}"
  erb :register_account
end

get '/account-settings' do
  redirect '/log-in' unless logged_in?

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
  else
    @error = "Passwords do not match"
    return erb :change_password
  end
end

get '/loyalty-card' do
  redirect '/log-in' unless session[:user_id]

  @user = DB[:Accounts].where(UserID: session[:user_id]).first

  if @user
    qrcode = RQRCode::QRCode.new("LoyaltyNum:#{@user[:UserID]}")

    @qr_svg = qrcode.as_svg(
      color: "4b2c20", 
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true,
      viewbox: true
    )
    erb :loyalty_card
  else
    "Error: Account not found in database."
  end
end

get '/my-orders' do
  if !logged_in?
    puts "User not logged in, redirecting to log-in page."
    redirect '/log-in'
  end

  puts "Fetching orders for user ID: #{session[:user_id]}"
  @current_orders = fetch_current_orders(session[:user_id])
  @past_orders = fetch_past_orders(session[:user_id])
  erb :my_orders
end

get '/log-out' do
  session.clear  
  redirect '/'
end

get '/forgot' do
  erb :forgot_password
end

get '/metrics' do
  #NEED TO CHECK SESSION TO SEE IF ACCOUNT HAS CORRECT LEVEL
  @metrics = analyze_sales_data
  puts @metrics
  erb :metrics_page
end