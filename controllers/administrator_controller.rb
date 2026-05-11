require_relative 'base_controller'
require 'wicked_pdf'
WickedPdf.config = {
  exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')
}

class AdminController < BaseController
  helpers AppHelpers

  before do
    unless session[:UserID] && session[:AccountType] == 'administrator'
      redirect '/'
    end
  end

  get '/staff-portal' do
    update_recent_login(session[:UserID]) if session[:UserID]
    erb :staff_portal
  end
  
  get '/user-tickets' do
    update_recent_login(session[:UserID]) if session[:UserID]
    @live_tickets = DB[:Tickets].where(TicketResolved: false).all
    @past_tickets = DB[:Tickets].where(TicketResolved: true).all
    erb :ticket_management
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
    update_recent_login(session[:UserID]) if session[:UserID]
    @flagged_accounts = DB[:Accounts].where(Flagged: true).all
    erb :flagged_accounts
  end

  get '/suspend-account/:id' do
    DB[:Accounts].where(UserID: params[:id]).update(Suspended: true)
    redirect '/flagged-accounts'
  end

  get '/metrics' do
    update_recent_login(session[:UserID]) if session[:UserID]
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

get '/generate-label/:id' do
  @order = DB[:Orders].where(OrderID: params[:id]).first
  @account = DB[:Accounts].where(UserID: @order[:UserID]).first
  
  @tracking_id = "TRK#{Array.new(10){rand(10)}.join}"
  @courier = "Royal Mail"
  
  qrcode = RQRCode::QRCode.new("https://www.royalmail.com/track-details/#{@tracking_id}")
  @qrcode_svg = qrcode.as_svg(color: "000", module_size: 6, standalone: true, viewbox: true)
  
  html = erb :shipping_label, layout: false
  pdf = ::WickedPdf.new.pdf_from_string(html)
  
  content_type 'application/pdf'
  attachment "Label_#{@order[:OrderID]}.pdf"
  pdf
end

post '/generate-return/:id' do
  @order = DB[:Orders].where(OrderID: params[:id]).first
  @account = DB[:Accounts].where(UserID: @order[:UserID]).first
  @external_id = params[:external_tracking_id]

  html = erb :return_label_template, layout: false
  pdf = ::WickedPdf.new.pdf_from_string(html)
  
  redirect back
end
end
