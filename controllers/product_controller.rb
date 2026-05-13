require_relative 'base_controller'

class ProductController < BaseController
  helpers AppHelpers

  def finalize_stamps(user_id, cart)
    stamps_to_add = 0
    cart.each do |item_data|
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

  get '/checkout' do
    redirect '/log-in' unless logged_in?
    @user = DB[:Accounts].where(UserID: session[:UserID]).first
    @subtotal = calculate_cart_total(session[:cart], @user)
    erb :checkout
  end

  post '/place-order' do
    redirect '/log-in' unless logged_in?
    user_record = DB[:Accounts].where(UserID: session[:UserID]).first
    subtotal = calculate_cart_total(session[:cart], user_record)
    total_to_charge = subtotal + 3.50

    order_id = DB[:Orders].insert(
      UserID: session[:UserID],
      OrderContents: session[:cart].to_json,
      OrderType: 'Delivery',
      PaymentMethod: params[:payment_timing] == 'online' ? 'Card' : 'Cash',
      totalCost: total_to_charge,
      IsCompleted: params[:payment_timing] == 'online' ? false : true,
      payment_status: params[:payment_timing] == 'online' ? 'Pending' : 'Paid'
    )

    if params[:payment_timing] == 'online'
      redirect "/external-payment-gateway?order_id=#{order_id}"
    else
      finalize_stamps(session[:UserID], session[:cart])
      session[:cart] = []
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
      cart = JSON.parse(order[:OrderContents])
      finalize_stamps(session[:UserID], cart)
      session[:cart] = [] 
      redirect '/order-success'
    else
      @error = "Payment Cancelled"
      redirect '/checkout'
    end
  end

  put '/add-to-cart' do
    session[:cart] ||= { }

    # for bean item key is:
    # item_key = origin_[pack_weight]_roast
    # for drink item its:
    # item_key = beverage_size_

    item_type = params[:item_type]

    begin
      if item_type == 'bean' 
        origin = params[:origin]
        pack_weight = params[:pack_weight]
        roast_level = params[:roast_level]
        item_key = "#{origin}_#{pack_weight}_#{roast_level}"

        if session[:cart][item_key] # item is in the basket, so just incrementing the quantity
          session[:cart][item_key][:quantity] += 1
        else
          session[:cart][item_key] = {
            item_type: item_type,
            origin: origin, 
            pack_weight: pack_weight,
            roast_level: roast_level,
            price: params[:price],
            quantity: 1 
          }
        end
      elsif item_type == 'drink'
        beverage = params[:beverage]
        drink_size = params[:drink_size]
        milk_type = params[:milk_type]
        item_key = "#{beverage}_#{drink_size}_#{milk_type}"
        if session[:cart][item_key] # same item exists, so just incrementing the quantity
          session[:cart][item_key][:quantity] += 1
        else
          session[:cart][item_key] = { 
            item_type: item_type,
            beverage: beverage,
            drink_size: drink_size,
            milk_type: milk_type,
            price: params[:price],
            quantity: 1 
          }
        end
      end

      p session[:cart]
      "Successfully added item to the cart".to_json()
    rescue => exception
      warn exception.message

      "Failed to add item to the cart".to_json()
    end
  end

  get '/order-success' do
    @order = DB[:Orders].where(UserID: session[:UserID]).order(Sequel.desc(:CreatedAt)).first
    @mock_token = "TXN-" + SecureRandom.hex(4).upcase 
    erb :order_success
  end
end