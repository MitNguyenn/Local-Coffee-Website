require 'sinatra'
require 'sinatra/reloader' if development?
load 'db/databaseFuctions.rb'

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
  user_email = params[:email]
  user_pass  = params[:password1]
  user_pass_hash = hashUserPassword(user_pass)
  puts "Login attempt for: #{user_email}"

  doesExist = checkAccountExists(user_email)
  if doesExist
    if user_pass_hash == collectUserData(user_email).passwordHash
      session[:user_id] = 1
      puts "Login successful for: #{user_email}"
      userData = collectUserData(user_email)
      template = File.read('views/home.erb')
      render = erb.new(template)
      render.result(binding)
    else
      @error = "Invalid password"
      erb :login_screen
    end
  else
    @error = "Invalid email"
    erb :login_screen
  end
end


get '/account-settings' do
  # need to figure out how to pull data from database
  # hard coded temp data
  @first_name = "First"
  @last_name = "Last"
  @dob = "01/01/01"
  @phone = "+44 07000 000000"
  @email = "test@gmail.com"
  @password = "password"
  @postcode = "S10 3AB"
  # address number/house name could be stored seperately
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

get '/register' do
  erb :register_account
end

post '/register' do
  "do something lmao"
end