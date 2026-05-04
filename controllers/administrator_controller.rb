require_relative 'base_controller'

class AdminController < BaseController
  helpers AppHelpers

  before do
    unless session[:UserID] && session[:AccountType] == 'administrator'
      redirect '/'
    end
  end

  get '/staff-portal' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    erb :staff_portal
  end
  
  get '/user-tickets' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    @live_tickets = DB[:Tickets].where(TicketResolved: false).all
    @past_tickets = DB[:Tickets].where(TicketResolved: true).all
    erb :ticket_management
  end

  get '/manage-accounts' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
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
      FirstName: params[:FirstName],
      LastName: params[:LastName],
      email: params[:email],
      PhoneNumber: params[:PhoneNumber],
      Postcode: params[:Postcode],
      AccountType: params[:AccountType]
    )
    if resetPassword
      DB[:Accounts].where(UserID: params[:id]).update(
        hashedPassword: BCrypt::Password.create("password123").to_s
      )
    end
    redirect '/manage-accounts'
  end

  get '/flagged-accounts' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    @flagged_accounts = DB[:Accounts].where(Flagged: true).all
    erb :flagged_accounts
  end

  get '/suspend-account/:id' do
    DB[:Accounts].where(UserID: params[:id]).update(Suspended: true)
    redirect '/flagged-accounts'
  end

  get '/metrics' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    @metrics = analyze_sales_data
    erb :metrics_page
  end

  get '/order-management/administrator' do 
    @completed_orders = DB[:Orders].all
    erb :order_correction_administrator
  end
  
  get '/stock-management' do
    @beans = Bean.all
    erb :stock_management
  end

  get '/user-tickets' do
    erb :ticket_management
  end

  get '/flagged-accounts' do
    erb :flagged_accounts
  end

end
