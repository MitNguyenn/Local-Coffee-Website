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

  # For the drink queue
get '/order-management/barista' do
  @orders = DB[:Orders]
    .join(:OrderItems, order_id: :order_id)
    .select(
      Sequel[:Orders][:order_id],
      Sequel[:Orders][:created_at],
      Sequel[:Orders][:order_type],
      Sequel[:Orders][:is_completed],
      Sequel[:OrderItems][:item_id],
      Sequel[:OrderItems][:quantity],
      Sequel[:OrderItems][:milk],
      Sequel[:OrderItems][:size],
      Sequel[:OrderItems][:product_type]
    )
    .all
    .group_by { |row| row[:order_id] }
  erb :order_management_barista
end

post '/order-management/barista' do
  DB[:Orders].where(order_id: params[:order_id]).update(is_completed: true)
  redirect '/order-management/barista'
end

get '/generate-label/:id' do
  @order = DB[:Orders].where(order_id: params[:id]).first
  return redirect '/order-management/barista' unless @order

  @account = DB[:Accounts].where(user_id: @order[:user_id]).first
  @tracking_id = "TRK#{Array.new(10){rand(10)}.join}"
  @courier = "Royal Mail"
  @qrcode = RQRCode::QRCode.new("https://royalmail.com/track-details/#{@tracking_id}")
  @qrcode_svg = @qrcode.as_svg(module_size: 4)

  html = erb :shipping_label, layout: false
  pdf = WickedPdf.new.pdf_from_string(html)
  content_type 'application/pdf'
  attachment "Label_#{@order[:order_id]}.pdf"
  pdf
end

post '/generate-return/:id' do
  @order = DB[:Orders].where(order_id: params[:id]).first
  return redirect '/order-management/barista' unless @order

  @account = DB[:Accounts].where(user_id: @order[:user_id]).first
  @tracking_id = "RTN#{Array.new(10) { rand(10) }.join}"
  @courier = "Royal Mail"
  @qrcode = RQRCode::QRCode.new("https://royalmail.com/track-details/#{@tracking_id}")
  @qrcode_svg = @qrcode.as_svg(module_size: 4)

  html = erb :return_label_template, layout: false
  pdf = WickedPdf.new.pdf_from_string(html)
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
    DB[:Tickets].where(ticket_id: params[:id]).update(ticket_resolved: true)

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
    DB[:Tickets].where(ticket_id: params[:id]).update(ticket_resolved: true)

    redirect '/refund-tickets'
  end
end

