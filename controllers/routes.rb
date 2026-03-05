require 'sinatra'
require 'sinatra/reloader' if development?
require "bcrypt"

enable :sessions

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

get '/register' do
  erb :register_account
end

post '/register' do
  "do something lmao"
end