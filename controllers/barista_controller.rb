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

  get '/manage-loyalty-cards' do
    @accounts = DB[:Accounts].all
    erb :manage_loyalty_cards
  end 

  post '/update-stamps' do

    target_user_id = params[:user_id]
    new_count = params[:stamp_count].to_i
    DB[:Accounts].where(UserID: target_user_id).update(StampCount: new_count)

    redirect '/manage-loyalty-cards'
  end
end