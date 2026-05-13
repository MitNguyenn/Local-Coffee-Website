require_relative 'base_controller'
require 'wicked_pdf'
WickedPdf.configure do |config|
  config.exe_path = Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')
end

class AdminController < BaseController
  helpers AppHelpers

  before do
    unless session[:user_id] && session[:account_type] == 'administrator'
      redirect '/'
    end
  end

  get '/manage-accounts' do
    @accounts = DB[:Accounts].all
    erb :account_management
  end

  get '/edit-account/:id' do
    @account = DB[:Accounts].where(user_id: params[:id]).first
    erb :edit_account
  end

  post '/edit-account/:id' do
    resetPassword = params[:reset_password] == "on"
    
    DB[:Accounts].where(user_id: params[:id]).update(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      phone_number: params[:phone_number],
      postcode: params[:postcode],
      account_type: params[:account_type]
    )
    if resetPassword
      DB[:Accounts].where(user_id: params[:id]).update(
        hashed_password: BCrypt::Password.create("password123").to_s
      )
    end
    redirect '/manage-accounts'
  end

  get '/flagged-accounts' do
    @flagged_accounts = DB[:Accounts].where(flagged: true).all
    erb :flagged_accounts
  end

  get '/suspend-account/:id' do
    DB[:Accounts].where(user_id: params[:id]).update(suspended: true)
    redirect '/flagged-accounts'
  end

  get '/order-management/administrator' do 
    @completed_orders = DB[:Orders].all
    erb :order_correction_administrator
  end

  get '/employee-accounts' do
    employees = DB[:Accounts].where(account_type: ['barista', 'manager', 'administrator']).all
    @grouped_accounts = employees.group_by { |acc| acc[:account_type] }

    erb :employee_accounts
  end

  post '/delete-account/:id' do
    DB[:Accounts].where(user_id: params[:id]).delete

    redirect '/employee-accounts'
  end
end
