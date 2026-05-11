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

  get '/generate-label/:id' do
  @order = DB[:Orders].where(OrderID: params[:id]).first
  @account = DB[:Accounts].where(UserID: @order[:UserID]).first
  
  @tracking_id = "TRK#{Array.new(10){rand(10)}.join}"
  @courier = "Royal Mail"
  
  @qrcode = RQRCode::QRCode.new("https://www.royalmail.com/track-details/#{@tracking_id}")
  
  html = erb :shipping_label, layout: false
  pdf = WickedPdf.new.pdf_from_string(html)
  
  content_type 'application/pdf'
  attachment "Label_#{@order[:OrderID]}.pdf"
  pdf
end

post '/generate-return/:id' do
  @order = DB[:Orders].where(OrderID: params[:id]).first
  @account = DB[:Accounts].where(UserID: @order[:UserID]).first
  @external_id = params[:external_tracking_id]

  html = erb :return_label_template, layout: false
  pdf = WickedPdf.new.pdf_from_string(html)
  
  redirect back
end
end

