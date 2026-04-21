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
  id = [params[:id]]

  if @type == 'bean'
    @item = Bean[id]
    @template = :bean_details
  elsif @type == 'drink'
    @item = Drink[id]
    @template = :drink_details
  else 
    halt 404, "Product type not found."
  end

  erb @template
end

post '/add-to-basket' do
  session[:basket] ||= []
  
  item_id   = params[:id]
  item_type = params[:type] 

  session[:basket] << { id: item_id, type: item_type }

  content_type :json
  { count: session[:basket].length }.to_json
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

  user = DB[:Accounts].where(email: @email).first
  
  if user && BCrypt::Password.new(user[:hashedPassword]) == @password then
    session[:UserID] = user[:UserID]
    session[:AccountType] = user[:AccountType]
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

#Refactor <15 lines
post '/register' do
  email = params[:email]
  password1 = params[:password1]
  password2 = params[:password2]
  FirstName = params[:FirstName]
  LastName = params[:LastName]
  PhoneNumber = params[:PhoneNumber]
  Address = params[:Address]
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
    Address: Address,
    Postcode: postcode,
    AccountType: 'customer'
  )

  user.Address = params[:Address] 
  user.AccountType = 'customer'

  session[:UserID] = user.UserID
  redirect '/'
rescue => e
  @error = "Registration failed: #{e.message}"
  erb :register_account
end

get '/account-settings' do
  redirect '/log-in' unless logged_in?

  @user = DB[:Accounts].where(UserID: session[:UserID]).first

  erb :account_settings
end

post '/update-account' do
  redirect '/log-in' unless session[:UserID]

  DateTime_of_birth = params[:Date_of_birth] ? DateTime.parse(params[:Date_of_birth]) : nil

  DB[:Accounts].where(UserID: session[:UserID]).update(
    FirstName:     params[:FirstName],
    LastName:      params[:LastName],
    Postcode:       params[:Postcode],
    Date_of_birth:  DateTime_of_birth

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
  redirect '/log-in' unless session[:UserID]

  @user = DB[:Accounts].where(UserID: session[:UserID]).first

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

  puts "Fetching orders for user ID: #{session[:UserID]}"
  @current_orders = fetch_current_orders(session[:UserID])
  @past_orders = fetch_past_orders(session[:UserID])
  erb :my_orders
end

get '/log-out' do
  session.clear  
  redirect '/log-in'
end

get '/forgot' do
  erb :forgot_password
end

post 'forgot-password' do
  # =begin
  # =end
  forgot_email = params[:email]

  code = rand(000000..999999)
end

get '/metrics' do
  redirect '/log-in' unless session[:UserID]
  redirect '/' unless session[:AccountType] == 'manager' || session[:AccountType] == 'administrator'
  @metrics = analyze_sales_data
  puts @metrics
  erb :metrics_page
end

#Refactor <15 lines
post '/help' do
  form_username = params[:form_username]
  form_useremail = params[:form_useremail]
  problem_type = params[:problem_type]
  request_description = params[:form_request_description]
  
  userid = DB[:Accounts].where(email: form_useremail).get(:UserID)
  #match useremail to ID?
  if userid.nil?
    @error = "Account not found!"
    erb :help
  end

  if request_description.empty?
    @error = "Blank description!"
    erb :help
  end

  ticket = Ticket.create(
  UserID: userid,
  ticketType: problem_type,
  ticketContent: request_description
  )
  redirect "/"
end

get '/user-tickets' do
  redirect '/log-in' unless session[:UserID]
  redirect '/' unless session[:AccountType] == 'manager' || session[:AccountType] == 'administrator'

  @live_tickets = DB[:Tickets].where(TicketResolved: false).all
  @past_tickets = DB[:Tickets].where(TicketResolved: true).all
  erb :ticket_management
end

get '/ticket/:id' do
  redirect '/log-in' unless session[:UserID]
  redirect '/' unless session[:AccountType] == 'manager' || session[:AccountType] == 'administrator'

  @ticket = DB[:Tickets].where(ticketID: params[:id]).first
  erb :ticket_resolve
end

get '/manage-accounts' do
  redirect '/log-in' unless session[:UserID]
  redirect '/' unless session[:AccountType] == 'administrator'

  @accounts = DB[:Accounts].all
  erb :account_management
end

get '/edit-account/:id' do
  redirect '/log-in' unless session[:UserID]
  redirect '/' unless session[:AccountType] == 'administrator'

  @account = DB[:Accounts].where(UserID: params[:id]).first
  erb :edit_account
end

post '/edit-account/:id' do
  redirect '/log-in' unless session[:UserID]
  redirect '/' unless session[:AccountType] == 'administrator'

  resetPassword = params[:reset_password] == "on"
  if resetPassword
    newPassword = "password123"
  end

  DB[:Accounts].where(UserID: params[:id]).update(
    FirstName: params[:FirstName],
    LastName: params[:LastName],
    email: params[:email],
    PhoneNumber: params[:PhoneNumber],
    Postcode: params[:Postcode],
    AccountType: params[:AccountType]
  )

  DB[:Accounts].where(UserID: params[:id]).update(
    hashedPassword: BCrypt::Password.create(newPassword).to_s
  ) if resetPassword

  redirect '/manage-accounts'
end

get '/manage-accounts-delete/:id' do
  redirect '/log-in' unless session[:UserID]
  redirect '/' unless session[:AccountType] == 'administrator'

  DB[:Accounts].where(UserID: params[:id]).delete
  redirect '/manage-accounts'
end


get '/view-basket' do
  @basket_items = []
  @total = 0
  
  if session[:basket]
    session[:basket].each do |item_data|
      # Assuming you updated add-to-basket to store {id: 1, type: 'bean'}
      item = item_data[:type] == 'bean' ? Bean[item_data[:id]] : Drink[item_data[:id]]
      if item
        @basket_items << item
        @total += item[:Price] 
      end
    end
  end
  erb :view_basket
end

post '/place-order' do
  redirect '/log-in' unless logged_in?
  
  total = calculate_basket_total(session[:basket]) 
  
  order = Order.create(
    UserID: session[:UserID],
    OrderDate: Time.now,
    TotalAmount: total,
    Status: 'Processing'
  )
  
  session[:basket].each do |item_data|
    OrderItem.create(
      OrderID: order.OrderID,
      ProductID: item_data[:id],
      ProductType: item_data[:type]
    )
  end
  
  session[:basket] = []
  redirect '/order-success'
end

get '/checkout' do
  @subtotal = 0
  @basket_items = []

  if session[:basket]
    session[:basket].each do |item_data|
      # item_data looks like { id: "1", type: "bean" }
      id = item_data[:id]
      type = item_data[:type]

      # Find the item in the correct table
      item = (type == 'bean') ? Bean[id] : Drink[id]

      if item
        @basket_items << item
        @subtotal += item[:Price] # Ensure :Price matches your DB column name
      end
    end
  end
  
  @user = Account[session[:UserID]] if logged_in?
  erb :checkout
end

def calculate_basket_total(basket)
  return 0 if basket.nil?
  basket.sum do |item_data|
    item = item_data[:type] == 'bean' ? Bean[item_data[:id]] : Drink[item_data[:id]]
    item ? item[:Price] : 0
  end
end 