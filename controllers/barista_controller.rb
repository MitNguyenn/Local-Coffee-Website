require_relative 'base_controller'

class BaristaController < BaseController
  before do
    redirect '/log-in' unless session[:UserID]
    unless session[:AccountType] == 'barista'
      redirect '/' 
    end
  end

  get '/staff-portal' do
    erb :staff_portal
  end
end