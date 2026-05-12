require_relative 'base_controller'
require 'wicked_pdf'

class BaristaController < BaseController
  before do
    unless session[:UserID] && ['barista', 'manager', 'administrator'].include?(session[:AccountType])
      redirect '/'
    end
  end

  get "/staff-portal" do
    erb :staff_portal
  end

  get '/manage-loyalty-cards' do
    redirect '/' unless session[:AccountType] == 'barista'
    @accounts = DB[:Accounts].where(AccountType: 'customer').all
    erb :manage_loyalty_cards
  end

  post '/update-stamps' do

    target_user_id = params[:user_id]
    new_count = params[:stamp_count].to_i
    DB[:Accounts].where(UserID: target_user_id).update(StampCount: new_count)

    redirect '/manage-loyalty-cards'
  end

  get "/print-order-label" do
    # Changed from @current_orders to @orders to match typical view naming
    @orders = DB[:Orders].where(IsCompleted: false).all 
    erb :print_label
  end

  get '/generate-label/:id' do
    @order = DB[:Orders].where(OrderID: params[:id]).first
    
    # Redirect if order doesn't exist to avoid a crash
    return redirect back unless @order
    
    @account = DB[:Accounts].where(UserID: @order[:UserID]).first
    @tracking_id = "TRK#{Array.new(10){rand(10)}.join}"
    @courier = "Royal Mail"
    @qrcode = RQRCode::QRCode.new("https://royalmail.com{@tracking_id}")
    
    html = erb :shipping_label, layout: false
    
    # Generate the PDF
    pdf = WickedPdf.new.pdf_from_string(html)
    
    content_type 'application/pdf'
    attachment "Label_#{@order[:OrderID]}.pdf"
    
    pdf
  end

  get '/generate-return' do
    @orders = DB[:Orders].where(IsCompleted: 1).all
    erb :create_return
  end

  post '/generate-return/:id' do
    @order = DB[:Orders].where(OrderID: params[:id]).first
    @account = DB[:Accounts].where(UserID: @order[:UserID]).first
    @external_id = params[:external_tracking_id]

    html = erb :return_label_template, layout: false
    pdf = WickedPdf.new.pdf_from_string(html)
    
    # Set headers so the browser treats the response as a file download
    content_type 'application/pdf'
    attachment "Return_Label_#{@order[:OrderID]}.pdf"
    pdf
  end
end

