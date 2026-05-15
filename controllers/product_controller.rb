before ['/place-order*', '/external-payment-gateway*', '/payment-callback*', '/order-success*', '/checkout'] do
  redirect '/log-in' unless session[:user_id]
end

def finalize_stamps_from_order(user_id, order_id)
  items = DB[:OrderItems].where(order_id: order_id).all
  stamps = items.sum do |item|
    item[:product_type] == 'drink' ? item[:quantity] : item[:quantity] * 3
  end
  current = DB[:Accounts].where(user_id: user_id).get(:stamp_count) || 0
  DB[:Accounts].where(user_id: user_id).update(stamp_count: (current + stamps) % 10)
end

def cart_contains_drink
  return false unless session[:cart]
  session[:cart].any? { |_key, data| data[:item_type] == 'drink' }
end

def flip_coin
  rand(0.0..1.0) > 0.05
end

get '/product/' do
  @type = params[:type]
  if @type == 'bean'
    @item = Bean[params[:origin]]
    @bean_packs = DB[:BeansPackWeightPriceMarkupMultipliers].all
    @bean_roast_levels = DB[:BeanRoastLevels].all
    @template = :bean_details
  elsif @type == 'drink'
    @item = Drink[params[:beverage]]
    @drink_sizes = DB[:DrinkSizePriceMarkupMultipliers].all
    @milk_types = DB[:MilkTypes].all
    @template = :drink_details
  else
    halt 404, "Product type not found."
  end
  erb @template
end

post '/place-order' do
  redirect '/log-in' unless session[:user_id]
  user = DB[:Accounts].where(user_id: session[:user_id]).first
  total_cost = params[:total_cost].to_f.round(2)
  address  = params[:address]
  postcode = params[:postcode]

  order_id = DB[:Orders].insert(
    user_id: user[:user_id],
    created_at: Time.now,
    address: address,
    postcode: postcode,
    total_cost: total_cost,
    payment_is_completed: false,
    order_is_completed: false
  )

  session[:cart].each do |key, data|
    if data[:item_type] == 'bean'
      DB[:OrderItems].insert(
        order_id:     order_id,
        product_type: data[:item_type],
        item_id:      data[:origin],
        quantity:     data[:quantity],
        pack_weight:  data[:pack_weight],
        roast_level:  data[:roast_level]
      )
      kg_bought = (data[:pack_weight] * data[:quantity]) / 1000.0
      DB[:Beans].where(origin: data[:origin]).update(
        stock_mass: Sequel[:stock_mass] - kg_bought
      )
    else
      DB[:OrderItems].insert(
        order_id:     order_id,
        product_type: data[:item_type],
        item_id:      data[:beverage],
        quantity:     data[:quantity],
        milk_type:    data[:milk_type],
        drink_size:   data[:drink_size]
      )
    end
  end

  session[:cart].clear
  session[:contains_drink] = false

  if params[:payment] == 'pay-now'
    redirect "/external-payment-gateway?order_id=#{order_id}"
  else
    finalize_stamps_from_order(user[:user_id], order_id)
    redirect '/order-success'
  end
end

get '/external-payment-gateway' do
  @order_id = params[:order_id]
  erb :mock_gateway, layout: false
end

get '/payment-callback' do
  redirect '/log-in' unless session[:user_id]
  order_id = params[:order_id].to_i
  status   = params[:status]
  if status == 'success'
    DB[:Orders].where(order_id: order_id).update(payment_is_completed: true)
    finalize_stamps_from_order(session[:user_id], order_id)
    redirect '/order-success'
  else
    DB[:Orders].where(order_id: order_id).delete
    redirect '/order-fail'
  end
end

get '/order-fail' do
  erb :order_fail
end

get '/order-success' do
  erb :order_success
end

put '/remove-from-cart' do
  key = params[:item_id]
  session[:cart].delete(key)
  session[:contains_drink] = cart_contains_drink
  "Success".to_json
end

put '/update-cart-item-quantity' do
  key = params[:item_id]
  action = params[:action]
  if action == "add"
    session[:cart][key][:quantity] += 1
  else
    current_quantity = session[:cart][key][:quantity]
    if current_quantity <= 1
      session[:cart].delete(key)
    else
      session[:cart][key][:quantity] -= 1
    end
  end
  session[:contains_drink] = cart_contains_drink
  "Success".to_json
end

put '/add-to-cart' do
  session[:cart] ||= {}
  session[:contains_drink] ||= false
  item_type = params[:item_type]
  begin
    if item_type == 'bean'
      origin = params[:origin]
      pack_weight = params[:pack_weight]
      roast_level = params[:roast_level]
      item_key = "#{origin}_#{pack_weight}_#{roast_level}"
      if session[:cart][item_key]
        session[:cart][item_key][:quantity] += 1
      else
        session[:cart][item_key] = {
          item_type: item_type,
          origin: origin,
          pack_weight: pack_weight.to_f,
          roast_level: roast_level,
          price: params[:price].to_f,
          quantity: 1
        }
      end
    elsif item_type == 'drink'
      beverage = params[:beverage]
      drink_size = params[:drink_size]
      milk_type = params[:milk_type]
      item_key = "#{beverage}_#{drink_size}_#{milk_type}"
      if session[:cart][item_key]
        session[:cart][item_key][:quantity] += 1
      else
        session[:cart][item_key] = {
          item_type: item_type,
          beverage: beverage,
          drink_size: drink_size,
          milk_type: milk_type,
          price: params[:price].to_f,
          quantity: 1
        }
      end
    end
    session[:contains_drink] = cart_contains_drink
    "Successfully added item to the cart".to_json
  rescue => exception
    warn exception.message
    "Failed to add item to the cart".to_json
  end
end