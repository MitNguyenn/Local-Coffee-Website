require 'sinatra'
require 'sinatra/reloader' if development?

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
  erb :login_screen
end

post '/login' do
  user_email = params[:email]
  user_pass  = params[:password1]

  puts "Login attempt for: #{user_email}"

  if user_email == "admin@coffee.com" && user_pass == "password123"
    session[:user_id] = 1
    redirect '/'
  else
    @error = "Invalid email or password"
    erb :login
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

get '/login' do
  @email = ""
  @password1 = ""
  @password2 = ""
  erb :login_screen
end

post '/login' do
  email = params[:email]
  password1 = params[:password1]
  password2 = params[:password2]
  "email = #{email}, password1 = #{password1}, password2 = #{password2}"
end
