require_relative 'base_controller'

class ProductController < BaseController
  helpers AppHelpers

  def finalize_stamps(user_id, basket)
    stamps_to_add = 0
    basket.each do |item_data|
      if item_data['type'] == 'bean'
        stamps_to_add += 3
      elsif item_data['type'] == 'drink'
        stamps_to_add += 1
      end
    end

    current_stamps = DB[:Accounts].where(UserID: user_id).get(:StampCount) || 0
    final_count = (current_stamps + stamps_to_add) % 10

    DB[:Accounts].where(UserID: user_id).update(StampCount: final_count)
  end

  # product page
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

  get '/coffee-beans' do
    update_recent_login(session[:UserID]) if session[:UserID]
    @beans = Bean.all
    erb :beans
  end

  get '/drinks' do
    update_recent_login(session[:UserID]) if session[:UserID]
    @drinks = Drink.all
    erb :drinks
  end

  get '/view-basket' do
    erb :basket
  end

  get '/checkout' do
    redirect '/log-in' unless logged_in?
    @user = DB[:Accounts].where(UserID: session[:UserID]).first
    @subtotal = calculate_basket_total(session[:basket], @user)
    erb :checkout
  end

  post '/place-order' do
    redirect '/log-in' unless logged_in?
    user_record = DB[:Accounts].where(UserID: session[:UserID]).first
    subtotal = calculate_basket_total(session[:basket], user_record)
    total_to_charge = subtotal + 3.50

    order_id = DB[:Orders].insert(
      UserID: session[:UserID],
      OrderContents: session[:basket].to_json,
      OrderType: 'Delivery',
      PaymentMethod: params[:payment_timing] == 'online' ? 'Card' : 'Cash',
      totalCost: total_to_charge,
      IsCompleted: params[:payment_timing] == 'online' ? false : true,
      payment_status: params[:payment_timing] == 'online' ? 'Pending' : 'Paid'
    )

    if params[:payment_timing] == 'online'
      redirect "/external-payment-gateway?order_id=#{order_id}"
    else
      finalize_stamps(session[:UserID], session[:basket])
      session[:basket] = []
      redirect '/order-success'
    end
  end

  get '/external-payment-gateway' do
    @order_id = params[:order_id]
    erb :mock_gateway, layout: false 
  end

  get '/payment-callback' do
    order = DB[:Orders].where(OrderID: params[:order_id]).first
    if params[:status] == 'success' && order
      DB[:Orders].where(OrderID: params[:order_id]).update(IsCompleted: true, payment_status: 'Paid')
      basket = JSON.parse(order[:OrderContents])
      finalize_stamps(session[:UserID], basket)
      session[:basket] = [] 
      redirect '/order-success'
    else
      @error = "Payment Cancelled"
      redirect '/checkout'
    end
  end

  post '/add-to-basket' do
    if session[:basket].empty? 
      session[:basket] = { }
    end

    # [item_key][quantity, total price = quantity * item_price]
    # for bean item key is:
    # item_key = origin_[pack_weight]_roast
    # for drink item its:
    # item_key = beverage_size_

    item_key = ""

    if item_type == 'bean' 
      origin = params[:id]
      pack_weight = params[:pack_weight]
      roast_level = params[:roast_level]
      item_key = "#{origin}_#{pack_weight}_#{roast_level}"
    elsif item_type == 'drink'
      beverage = params[:id]
      size = params[:size]
      milk_type = params[:milk_type]
      item_key = "#{beverage}_#{size}_#{milk_type}"
    end

    if session[:basket][item_key]
      session[:basket][item_key][:quantity] += 1
    else
      session[:basket][item_key] = { 
        id: item_id, 
        type: item_type, 
        quantity: 1 
      }
    end

    redirect back
  end

  get '/order-success' do
    @order = DB[:Orders].where(UserID: session[:UserID]).order(Sequel.desc(:CreatedAt)).first
    @mock_token = "TXN-" + SecureRandom.hex(4).upcase 
    erb :order_success
  end
end

def calculate_basket_total(basket, user)
  return 0.0 if basket.nil? || basket.empty?
  total = 0.0
  drink_prices = []
  basket.each do |item_data|
    table = (item_data[:type] == 'bean') ? :Beans : :Drinks
    id_col = (item_data[:type] == 'bean') ? :BeanID : :DrinkID
    item = DB[table].where(id_col => item_data[:id]).first
    if item
      price = item[:Price].to_f
      total += price
      drink_prices << price if item_data[:type] == 'drink'
    end
  end
  if user && user[:StampCount] >= 9 && !drink_prices.empty?
    discount = [drink_prices.min, 5.0].min 
    total -= discount
  end
  total
end
