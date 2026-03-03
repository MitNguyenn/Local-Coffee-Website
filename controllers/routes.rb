require 'sinatra'
require 'sinatra/reloader' if development?
require "bcrypt"


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
  user_email = params[:email]
  user_pass  = params[:password1]

  user = collect_user_data(user_email) # Assume this returns a user object or nil

  if user && BCrypt::Password.new(user.password_hash) == user_pass
    session[:user_id] = user.id
    puts "Login successful for: #{user_email}"
    redirect '/home' # Better to redirect than manually render
  else
    @error = "Invalid email or password"
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