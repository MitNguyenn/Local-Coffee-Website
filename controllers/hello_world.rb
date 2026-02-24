require 'sinatra'
require 'sinatra/reloader' if development?

get '/hello_world' do
  "Hello, World!"
end

get '/' do
  erb :home
end

