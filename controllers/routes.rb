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
  erb :account_settings
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
  erb :log_out
end