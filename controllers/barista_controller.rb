require_relative 'base_controller'
require 'wicked_pdf'

class BaristaController < BaseController
  before do
    unless session[:user_id]
      redirect '/log-in'
    end

    if session[:account_type] == 'customer'
      redirect '/'
    end

    unless ['barista', 'manager', 'administrator'].include?(session[:account_type])
      redirect '/'
    end
  end

  get '/staff-portal' do
  erb :staff_portal
end

  get '/manage-loyalty-cards' do
    redirect '/' unless session[:account_type] == 'barista'
    @accounts = DB[:Accounts].where(account_type: 'customer').all
    erb :manage_loyalty_cards
  end

  post '/update-stamps' do

    target_user_id = params[:user_id]
    new_count = params[:stamp_count].to_i
    DB[:Accounts].where(user_id: target_user_id).update(stamp_count: new_count)

    redirect '/manage-loyalty-cards'
  end

  get "/print-order-label" do
    # Changed from @current_orders to @orders to match typical view naming
    @orders = DB[:Orders].where(is_completed: false).all 
    erb :print_label
  end

  get '/generate-label/:id' do
    @order = DB[:Orders].where(order_id: params[:id]).first
    
    # Redirect if order doesn't exist to avoid a crash
    return redirect back unless @order
    
    @account = DB[:Accounts].where(user_id: @order[:user_id]).first
    @tracking_id = "TRK#{Array.new(10){rand(10)}.join}"
    @courier = "Royal Mail"
    @qrcode = RQRCode::QRCode.new("https://royalmail.com{@tracking_id}")
    
    html = erb :shipping_label, layout: false
    
    # Generate the PDF
    pdf = WickedPdf.new.pdf_from_string(html)
    
    content_type 'application/pdf'
    attachment "Label_#{@order[:order_id]}.pdf"
    
    pdf
  end

  get '/generate-return' do
    @orders = DB[:Orders].where(is_completed: 1).all
    erb :create_return
  end

  post '/generate-return/:id' do
    @order = DB[:Orders].where(order_id: params[:id]).first
    @account = DB[:Accounts].where(user_id: @order[:user_id]).first
    @external_id = params[:external_tracking_id]

    html = erb :return_label_template, layout: false
    pdf = WickedPdf.new.pdf_from_string(html)
    
    # Set headers so the browser treats the response as a file download
    content_type 'application/pdf'
    attachment "Return_Label_#{@order[:order_id]}.pdf"
    pdf
  end

  get '/user-tickets' do
    @live_tickets = DB[:Tickets].where(ticket_resolved: false).all
    @past_tickets = DB[:Tickets].where(ticket_resolved: true).all
    erb :ticket_management
  end

  get '/ticket/:id' do
    @ticket = DB[:Tickets].where(ticket_id: params[:id]).first

    erb :ticket_resolve
  end

  post '/resolve-ticket/:id' do
    DB[:Tickets].where(ticket_id: params[:id]).update(ticketResolved: true)

    redirect '/user-tickets'
  end

  get '/refund-tickets' do
    @live_tickets = DB[:Tickets].where(ticket_resolved: false, ticket_type: 'Refund').all
    @past_tickets  = DB[:Tickets].where(ticket_resolved: true,  ticket_type: 'Refund').all

    erb :refund_management
  end

  get '/refund/:id' do
    @ticket = DB[:Tickets].where(ticket_id: params[:id]).first

    erb :refund_resolve
  end

  post '/refund/:id' do
    DB[:Tickets].where(ticket_id: params[:id]).update(ticketResolved: true)

    redirect '/refund-tickets'
  end
end

