require 'sinatra'
require 'sinatra/reloader' if development?

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
  erb :login_screen
end

post '/login' do
  user = User.find_by(email: params[:email])
  if user && user.password == params[:password1]
    session[:user_id] = user.id
    redirect '/'
  else
    @error = "Invalid credentials"
    erb :login
  end
end


get '/account-settings' do
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

