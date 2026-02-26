require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  "home"
end

get '/hello_world' do
  "Hello, World!"
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