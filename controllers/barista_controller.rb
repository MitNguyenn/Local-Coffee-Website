# Barista order processing and ticket handling routes.

require 'wicked_pdf'
require 'json'

before [
  '/staff-portal*', 
  '/manage-loyalty-cards*', 
  '/update-stamps*', 
  '/order-management/barista*', 
  '/generate-label*', 
  '/generate-return*', 
  '/user-tickets*', 
  '/ticket*', 
  '/resolve-ticket*', 
  '/refund-tickets*', 
  '/refund*', 
  '/daily-summary*', 
  '/sales-history*',
  '/place-order/*'
] do
  unless session[:user_id]
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
  redirect '/' if session[:account_type] == 'customer' 
  @accounts = DB[:Accounts].where(account_type: 'customer').all
  erb :manage_loyalty_cards
end

get '/order-management/barista' do
  @orders = DB[:Orders]
    .join(:OrderItems, order_id: :order_id)
    .select(
      Sequel[:Orders][:order_id],
      Sequel[:Orders][:created_at],
      Sequel[:Orders][:order_is_completed],
      Sequel[:OrderItems][:item_id],
      Sequel[:OrderItems][:quantity],
      Sequel[:OrderItems][:milk_type],
      Sequel[:OrderItems][:drink_size],
      Sequel[:OrderItems][:product_type]
    )
    .order(Sequel.desc(Sequel[:Orders][:order_id])) 
    .all
    .group_by { |row| row[:order_id] }
    
  erb :order_management_barista
end

get '/generate-label/:id' do
  @order = DB[:Orders].where(order_id: params[:id]).first
  return redirect '/order-management/barista' unless @order

  @account = DB[:Accounts].where(user_id: @order[:user_id]).first
  @tracking_id = "TRK#{Array.new(10){rand(10)}.join}"
  @courier = "Royal Mail"
  @qrcode = RQRCode::QRCode.new("royalmail.com{@tracking_id}")
  @qrcode_svg = @qrcode.as_svg(module_size: 4)

  html = erb :shipping_label, layout: false
  pdf = WickedPdf.new.pdf_from_string(html)
  content_type 'application/pdf'
  attachment "Label_#{@order[:order_id]}.pdf"
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

get '/refund-tickets' do
  @live_tickets = DB[:Tickets].where(ticket_resolved: false, ticket_type: 'Refund').all
  @past_tickets = DB[:Tickets].where(ticket_resolved: true,  ticket_type: 'Refund').all
  erb :refund_management
end

get '/refund/:id' do
  @ticket = DB[:Tickets].where(ticket_id: params[:id]).first
  erb :refund_resolve
end

get '/daily-summary' do
  today_start = Time.now - 86400 
  orders = DB[:Orders].where { created_at >= today_start }
  @daily_summary = {
    total_sales: orders.sum(:total_cost) || 0
  }
  erb :daily_summary
end

get '/sales-history' do
  @orders = DB[:Orders]
    .join(:OrderItems, order_id: :order_id)
    .select(
      Sequel[:Orders][:order_id].as(:order_id),  
      Sequel[:Orders][:created_at],
      Sequel[:Orders][:order_is_completed],
      Sequel[:OrderItems][:item_id],
      Sequel[:OrderItems][:quantity],
      Sequel[:OrderItems][:milk_type],
      Sequel[:OrderItems][:drink_size],
      Sequel[:OrderItems][:product_type]
    )
    .order(Sequel.desc(Sequel[:Orders][:order_id])) 
    .all
    .group_by { |row| row[:order_id] }
  
  erb :sales_history
end

get '/place-order/find-user' do
  @all_customers = DB[:Accounts].where(account_type: 'customer').all
  @selected_customer_id = session[:assigned_order_customer_id]
  @selected_customer = DB[:Accounts].where(user_id: @selected_customer_id).first if @selected_customer_id
  erb :place_order_find_user
end

get '/place-order/contents' do
  @selected_customer_id = session[:assigned_order_customer_id]
  return redirect '/place-order/find-user' unless @selected_customer_id

  @selected_customer = DB[:Accounts].where(user_id: @selected_customer_id).first
  
  @available_drinks = DB[:Drinks].all
  @available_beans  = DB[:Beans].where { stock_mass > 0 }.all
  @milk_types       = DB[:MilkTypes].all
  @drink_sizes      = DB[:DrinkSizePriceMarkupMultipliers].all
  @pack_weights     = DB[:BeansPackWeightPriceMarkupMultipliers].all
  @roast_levels     = DB[:BeanRoastLevels].all
  @common_items     = get_common_orders(5)

  erb :place_order_contents
end

post '/update-stamps' do
  target_user_id = params[:user_id]
  new_count = params[:stamp_count].to_i
  DB[:Accounts].where(user_id: target_user_id).update(stamp_count: new_count)
  redirect '/manage-loyalty-cards'
end

post '/order-management/barista' do
  DB[:Orders].where(order_id: params[:order_id]).update(order_is_completed: true)
  redirect '/order-management/barista'
end

post '/generate-return/:id' do
  @order = DB[:Orders].where(order_id: params[:id]).first
  return redirect '/order-management/barista' unless @order

  @account = DB[:Accounts].where(user_id: @order[:user_id]).first
  @tracking_id = "RTN#{Array.new(10) { rand(10) }.join}"
  @courier = "Royal Mail"
  @qrcode = RQRCode::QRCode.new("royalmail.com{@tracking_id}")
  @qrcode_svg = @qrcode.as_svg(module_size: 4)

  html = erb :return_label_template, layout: false
  pdf = WickedPdf.new.pdf_from_string(html)
  content_type 'application/pdf'
  attachment "Return_Label_#{@order[:order_id]}.pdf"
  pdf
end

post '/resolve-ticket/:id' do
  DB[:Tickets].where(ticket_id: params[:id]).update(ticket_resolved: true)
  redirect '/user-tickets'
end

post '/refund/:id' do
  DB[:Tickets].where(ticket_id: params[:id]).update(ticket_resolved: true)
  redirect '/refund-tickets'
end

post '/place-order/select-user' do
  session[:assigned_order_customer_id] = params[:customer_id]
  redirect '/place-order/contents'
end

post '/place-order/clear-user' do
  session.delete(:assigned_order_customer_id)
  redirect '/place-order/find-user'
end

post '/place-order/complete' do
  customer_id = session[:assigned_order_customer_id]
  order_items_json = params[:order_items_json]

  if customer_id.nil?
    status 400
    return "Error: Session timed out or no customer is assigned to this checkout transaction."
  end

  parsed_items = JSON.parse(order_items_json) rescue []
  if parsed_items.empty?
    status 400
    return "Error: Cannot checkout an empty shopping cart configuration."
  end

  DB.transaction do
    calculated_total = 0.0

    order_id = DB[:Orders].insert(
      user_id: customer_id.to_i,
      total_cost: 0.0,
      order_is_completed: false,
      payment_is_completed: true,
      created_at: Time.now
    )

    parsed_items.each do |item|
      item_id      = item['item_id']
      product_type = item['product_type']
      quantity     = item['quantity'].to_i

      if product_type == 'drink'
        base_price = DB[:Drinks].where(beverage: item_id).get(:regular_price).to_f
        size_mult  = DB[:DrinkSizePriceMarkupMultipliers].where(drink_size: item['size']).get(:markup_multiplier).to_f || 1.0
        milk_cost  = DB[:MilkTypes].where(milk_type: item['milk']).get(:price).to_f || 0.0
        
        item_cost = ((base_price * size_mult) + milk_cost) * quantity
        calculated_total += item_cost

        DB[:OrderItems].insert(
          order_id: order_id,
          item_id: item_id,
          product_type: 'drink',
          quantity: quantity,
          milk_type: item['milk'],
          drink_size: item['size']
        )

      elsif product_type == 'bean'
        price_per_250g = DB[:Beans].where(origin: item_id).get(:price_per_250g).to_f
        weight_mult    = DB[:BeansPackWeightPriceMarkupMultipliers].where(pack_weight: item['pack_weight'].to_f).get(:markup_multiplier).to_f || 1.0
        
        item_cost = (price_per_250g * weight_mult) * quantity
        calculated_total += item_cost

        kg_consumed = (item['pack_weight'].to_f / 1000.0) * quantity
        DB[:Beans].where(origin: item_id).update(stock_mass: Sequel[:stock_mass] - kg_consumed)

        DB[:OrderItems].insert(
          order_id: order_id,
          item_id: item_id,
          product_type: 'bean',
          quantity: quantity,
          pack_weight: item['pack_weight'].to_f,
          roast_level: item['roast_level']
        )
      end
    end

    DB[:Orders].where(order_id: order_id).update(total_cost: calculated_total.round(2))
    DB[:Accounts].where(user_id: customer_id.to_i).update(stamp_count: Sequel[:stamp_count] + parsed_items.sum { |i| i['quantity'].to_i })
  end

  session.delete(:assigned_order_customer_id)
  redirect '/order-management/barista'
end