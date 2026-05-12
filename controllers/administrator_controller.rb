require_relative 'base_controller'
require 'wicked_pdf'
WickedPdf.configure do |config|
  config.exe_path = Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')
end

class AdminController < BaseController
  helpers AppHelpers

  before do
    unless session[:UserID] && session[:AccountType] == 'administrator'
      redirect '/'
    end
  end
  
  

  get '/manage-accounts' do
    update_recent_login(session[:UserID]) if session[:UserID]
    @accounts = DB[:Accounts].all
    erb :account_management
  end

  get '/edit-account/:id' do
    @account = DB[:Accounts].where(UserID: params[:id]).first
    erb :edit_account
  end

  post '/edit-account/:id' do
    resetPassword = params[:reset_password] == "on"
    
    DB[:Accounts].where(UserID: params[:id]).update(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      PhoneNumber: params[:PhoneNumber],
      Postcode: params[:Postcode],
      AccountType: params[:AccountType]
    )
    if resetPassword
      DB[:Accounts].where(UserID: params[:id]).update(
        hashed_password: BCrypt::Password.create("password123").to_s
      )
    end
    redirect '/manage-accounts'
  end

  get '/flagged-accounts' do
    update_recent_login(session[:UserID]) if session[:UserID]
    @flagged_accounts = DB[:Accounts].where(Flagged: true).all
    erb :flagged_accounts
  end

  get '/suspend-account/:id' do
    DB[:Accounts].where(UserID: params[:id]).update(Suspended: true)
    redirect '/flagged-accounts'
  end

  get '/order-management/administrator' do 
    @completed_orders = DB[:Orders].all
    erb :order_correction_administrator
  end

end
