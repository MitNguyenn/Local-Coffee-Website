require_relative 'base_controller'

class BaristaController < BaseController
  redirect '/' if !logged_in? || session[:account_type] != 'barista'

  get '/staff-portal' do
    update_Recet_Login(session[:user_id]) if session[:user_id]
    erb :staff_portal
  end
end