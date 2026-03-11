require 'sinatra'
require 'bcrypt'
require_relative '../db/db.rb'
require_relative '../helpers/helpers'

get '/' do
  erb :home
end

get '/coffee-beans' do
  @beans = Bean.all
  erb :beans
end

get '/drinks' do
  @drinks = Drink.all
  erb :drinks
end

# product page
get '/product/' do
  @type = params[:type]

  if @type == 'bean'
    @item = Bean[params[:id]]
    @template = :bean_details
  elsif @type == 'drink'
    @item = Drink.where(BeanID: params[:bean_id], Beverage: params[:name]).first
    @template = :drink_details
  else 
    halt 404, "Product type not found."
  end

  erb @template
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
  email = params[:email]
  password1 = params[:password1]
  password2 = params[:password2]
  FirstName = params[:FirstName]
  LastName = params[:LastName]
  PhoneNumber = params[:PhoneNumber]
  postcode = params[:postcode]

  UserID = nil
  loop do
    UserID = rand(10000000..99999999)
    break unless Account[UserID]
  end

  unless str_email_address?(email)
    @error = "Invalid email format."
    return erb :register_account
  end

  # Validate phone number
  unless str_uk_telephone?(PhoneNumber)
    puts "Phone validation failed for input: #{PhoneNumber}"
    @error = "Invalid UK phone number."
    return erb :register_account
  end

  # Check passwords match
  unless password1 == password2
    @error = "Passwords do not match."
    return erb :register_account
  end

  # Validate password length
  unless str_min_length?(password1, 12)
    @error = "Password must be at least 12 characters."
    return erb :register_account
  end


  # Create new user account
  user = Account.create(
    UserID: UserID,
    FirstName: FirstName,
    LastName: LastName,
    email: email,
    #password_hash: BCrypt::Password.create(password).to_s,
    password: password1,
    PhoneNumber: PhoneNumber,
    Postcode: postcode,
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

  @user = DB[:Accounts].where(UserID: session[:user_id]).first

  erb :account_settings
end

post '/update-account' do
  redirect '/log-in' unless session[:user_id]

  DB[:Accounts].where(UserID: session[:user_id]).update(
    FirstName:     params[:FirstName],
    LastName:      params[:LastName],
    Postcode: params[:Postcode]
  )

  redirect '/account-settings?success=1'
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
  redirect '/log-in'
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
