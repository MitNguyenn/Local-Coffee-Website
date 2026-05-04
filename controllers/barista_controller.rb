require_relative 'base_controller'

class BaristaController < BaseController
  before do
    unless session[:UserID] && session[:AccountType] == 'barista'
      redirect '/'
    end
  end

  get '/staff-portal' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    erb :staff_portal
  end
end