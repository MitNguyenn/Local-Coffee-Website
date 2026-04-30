require_relative 'base_controller'

class BaristaController < BaseController
  redirect '/' if !logged_in? || session[:account_type] != 'barista'

  get '/staff-portal' do
    erb :staff_portal
  end
end