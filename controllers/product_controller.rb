before ['/checkout*', '/place-order*', '/external-payment-gateway*', '/payment-callback*', '/order-success*'] do
  redirect '/log-in' unless session[:user_id] # swapped logged_in? helper check for direct session lookup to stay robust
end

  def finalize_stamps(user_id)
    stamps_to_add = 0

    session[:cart].each do |key, data|
      if [data[:item_type]] == 'bean'
        stamps_to_add += 3*data[:quantity]
      elsif data[:item_type] == 'drink'
        stamps_to_add += data[:quantity]
      end
    end

    current_stamps = DB[:Accounts].where(user_id: user_id).get(:stamp_count) || 0
    final_count = (current_stamps + stamps_to_add) % 10

    DB[:Accounts].where(user_id: user_id).update(stamp_count: final_count)
  end

  def cart_contains_drink() 
    session[:cart].each do | key, data |
      if data[:item_type] == "drink"
        return true
      end
    end
    
    return false
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

  post '/checkout' do
    redirect '/log-in' unless logged_in?
    user = DB[:Accounts].where(user_id: session[:user_id]).first

    total_cost = params[:total_cost].to_f.round(2)
    @payment_successful    = nil
    payment_is_completed = false

    if params[:payment] == "pay-now"
      p "checking if payment is successful"
      @payment_successful = flip_coin()
      payment_is_completed = @payment_successful
    end

    address = params[:address]
    postcode = params[:postcode]

    # ===========Debugging messages=================
    # p "payment_successful = #{payment_successful}"
    # p "user_id = #{user[:user_id]}"
    # p "address = #{address}"
    # p "postcode = #{postcode}" 
    # p "total_cost = #{total_cost}"
    # p "payment_is_completed = #{payment_is_completed}"

    # session[:cart].each do | key, data |
    #   p data
    #   if data[:item_type] == "bean"
    #     p data[:item_type]
    #     p data[:origin]
    #     p data[:quantity]
    #     p data[:pack_weight]
    #     p data[:roast_level]
    #   else
    #     p data[:item_data]
    #     p data[:beverage]
    #     p data[:quantity]
    #     p data[:milk_type]
    #     p data[:drink_size]
    #   end
    # end
    # p "=================="
    # p

    if @payment_successful == true || @payment_successful == nil
      begin 
        order_id = DB[:Orders].insert(
          user_id: user[:user_id],
          created_at: Time.now,

          address: address,
          postcode: postcode,

          total_cost: total_cost,
          payment_is_completed: payment_is_completed,

          order_is_completed: false
        )
      rescue StandardError => e
        p "Failed to create order in db"
        puts "Caught an error: #{e.message}"
        puts "Error class: #{e.class}"
        return "Failed".to_json
      end

      session[:cart].each do | key, data |
        begin
          if data[:item_type] == 'bean'
            DB[:OrderItems].insert(
              order_id:     order_id,
              product_type: data[:item_type],
              item_id:      data[:origin],
              quantity:     data[:quantity],
              pack_weight:  data[:pack_weight],
              roast_level:  data[:roast_level]
            )

            grams_beans_bought = data[:pack_weight] * data[:quantity]
            kg_bought = grams_beans_bought / 1000.0

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
        rescue StandardError => e
          p "Failed to add order items to db"
          puts "Caught an error: #{e.message}"
          puts "Error class: #{e.class}"
          return "Failed".to_json
        end
      end

      p "Successfully placed order"
      finalize_stamps(session[:user_id])
      session[:cart].clear
      session[:contains_drink] = false
    end

    erb :mock_gateway, layout: false
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
    session[:contains_drink] = cart_contains_drink()

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

    session[:contains_drink] = cart_contains_drink()

    "Success".to_json
  end

  get '/external-payment-gateway' do
    erb :mock_gateway, layout: false
  end

  get '/payment-callback' do
    status  = params[:status]
    if status == "true"
      erb :order_success
    elsif status == "false"
      erb :order_fail
    else p "status = #{status}"
    end
  end
    

  put '/add-to-cart' do
    session[:cart] ||= { }
    session[:contains_drink] ||= false

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
        session[:contains_drink] = true
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
      
      session[:contains_drink] = cart_contains_drink
      "Successfully added item to the cart".to_json()
    rescue => exception
      warn exception.message

      "Failed to add item to the cart".to_json()
    end
  end
