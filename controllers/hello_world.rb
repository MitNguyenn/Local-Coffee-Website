require 'sinatra'

get '/hello_world' do
  "Hello, World!"
end

get '/' do
  erb :home
end

