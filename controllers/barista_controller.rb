require_relative 'base_controller'

class BaristaController < BaseController
  before do
    unless session[:UserID] && session[:account_type] == 'barista'
      redirect '/'
    end
  end

  get '/staff-portal' do
    update_Recet_Login(session[:user_id]) if session[:user_id]
    erb :staff_portal
  end
end