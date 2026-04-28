require_relative 'base_controller'

class AdminController < BaseController
  helpers AppHelpers
  before do
    redirect '/log-in' unless session[:UserID]
    unless ['manager', 'administrator'].include?(session[:AccountType])
      redirect '/' 
    end
  end

  get '/staff-portal' do
    erb :staffportal
  end

  get '/metrics' do
    @metrics = analyze_sales_data
    erb :metrics_page
  end

  get '/user-tickets' do
    @live_tickets = DB[:Tickets].where(TicketResolved: false).all
    @past_tickets = DB[:Tickets].where(TicketResolved: true).all
    erb :ticket_management
  end

  get '/manage-accounts' do
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
end
