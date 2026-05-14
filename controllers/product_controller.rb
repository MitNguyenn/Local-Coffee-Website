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

    current_stamps = DB[:Accounts].where(user_id: user_id).get(:stamp_count) || 0
    final_count = (current_stamps + stamps_to_add) % 10

    DB[:Accounts].where(user_id: user_id).update(stamp_count: final_count)
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
    update_recent_login(session[:user_id]) if session[:user_id]
    @beans = Bean.all
    erb :beans
  end

  get '/drinks' do
    update_recent_login(session[:user_id]) if session[:user_id]
    @drinks = Drink.all
    erb :drinks
  end

  def flip_coin()
    n = rand(0.0..1.0)
    chance_of_failure = 0.05
    if n > chance_of_failure
      true
    else 
      false
    end
  end

  def to_boolean(s)

    if s.downcase == "true"
      true
    elsif s.downcase == "false"
      false
    else
      nil
    end
  end

  put '/checkout' do
    begin 
      redirect '/log-in' unless logged_in?
      @user = DB[:Accounts].where(user_id: session[:user_id]).first
      
      delivery = params[:delivery]

      payment_successful    = nil
      paymenet_is_completed = false

      if to_boolean(params[:pay_now]) == true
        payment_is_completed = payment_successful = flip_coin
      end

      is_completed = false

      if payment_successful
        # some logic must be added to understand
        # whether the order will be collected or
        # delivered

        # I guess iterating over the cart twice
        # and finding a drink in it
        # using a drink_type in data
        # and then make like a contains_drink

        # if contains_drink
        #   order_type = "In-Person"
        #   location = "In-Store"
        #   ...
        # end

        order_id = db_connection[:Orders].insert(
          user_id: @user,
          created_at: Time.now,
          payment_is_completed: payment_is_completed,
          order_is_completed: false,
          total_cost: total_price
        )
        session[:cart].each do | key, data |
          if data[:item_type] == 'bean'
            db_connection[:OrderItems].insert(
              order_id:     order_id,
              product_type: data[:product_type],
              item_id:      data[:origin],
              quantity:     data[:quantity],
              pack_weight:  data[:pack_weight],
              roast_level:  data[:roast_level]
            )

            grams_beans_bought = data[:pack_weight] * data[:pack_weight]
            kg_bought = grams_beans_bought / 1000.0

            db_connection[:Beans].where(origin: data[:origin]).update(
              stock_mass: Sequel[:stock_mass] - kg_bought
            )
          else
            db_connection[:OrderItems].insert(
              order_id:     order_id,
              product_type: data[:item_data],
              item_id:      data[:beverage],
              quantity:     data[:quantity],
              milk_type:    data[:milk_type],
              drink_size:   data[:drink_size]
            )
          end
        end
      else
        # notify that payment is wrong or smth
      end

      "Success".to_json
    rescue
      "Fail".to_json
    end
  end

  # post '/place-order' do
  #   redirect '/log-in' unless logged_in?
  #   user_record = DB[:Accounts].where(user_id: session[:user_id]).first
  #   subtotal = calculate_cart_total(session[:cart], user_record)
  #   total_to_charge = subtotal + 3.50

  #   order_id = DB[:Orders].insert(
  #     user_id: session[:user_id],
  #     OrderContents: session[:cart].to_json,
  #     order_type: 'Delivery',
  #     payment_method: params[:payment_timing] == 'online' ? 'Card' : 'Cash',
  #     totalCost: total_to_charge,
  #     is_completed: params[:payment_timing] == 'online' ? false : true,
  #     payment_status: params[:payment_timing] == 'online' ? 'Pending' : 'Paid'
  #   )

  #   if params[:payment_timing] == 'online'
  #     redirect "/external-payment-gateway?order_id=#{order_id}"
  #   else
  #     finalize_stamps(session[:user_id], session[:cart])
  #     session[:cart] = []
  #     redirect '/order-success'
  #   end
  # end

  # get '/external-payment-gateway' do
  #   @order_id = params[:order_id]
  #   erb :mock_gateway, layout: false 
  # end

  # get '/payment-callback' do
  #   order = DB[:Orders].where(order_id: params[:order_id]).first
  #   if params[:status] == 'success' && order
  #     DB[:Orders].where(order_id: params[:order_id]).update(is_completed: true, payment_status: 'Paid')
  #     cart = JSON.parse(order[:OrderContents])
  #     finalize_stamps(session[:user_id], cart)
  #     session[:cart] = [] 
  #     redirect '/order-success'
  #   else
  #     @error = "Payment Cancelled"
  #     redirect '/checkout'
  #   end
  # end

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
        if session[:cart][item_key] # same item exists, so just incrementing the quantity
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

      p session[:cart]
      "Successfully added item to the cart".to_json()
    rescue => exception
      warn exception.message

      "Failed to add item to the cart".to_json()
    end
  end

  # get '/order-success' do
  #   @order = DB[:Orders].where(user_id: session[:user_id]).order(Sequel.desc(:created_at)).first
  #   @mock_token = "TXN-" + SecureRandom.hex(4).upcase 
  #   erb :order_success
  # end
end