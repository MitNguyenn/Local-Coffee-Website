require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  "home"
end

get '/hello_world' do
  "Hello, World!"
end

get '/login' do
  erb :login_screen
end