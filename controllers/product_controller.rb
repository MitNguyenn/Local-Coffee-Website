require_relative 'base_controller'

class ProductController < BaseController
  helpers AppHelpers

  def finalize_stamps(user_id, basket)
    stamps_to_add = 0
    basket.each do |item_data|
      if item_data['type'] == 'bean'
        puts "bean found"
        stamps_to_add += 3
      elsif item_data['type'] == 'drink'
        puts "drink found"
        stamps_to_add += 1
      end
    end

    current_stamps = DB[:Accounts].where(UserID: user_id).get(:StampCount) || 0
    final_count = (current_stamps + stamps_to_add) % 10
    puts current_stamps
    puts stamps_to_add
    puts final_count 

    DB[:Accounts].where(UserID: user_id).update(StampCount: final_count)
  end



  get '/coffee-beans' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    @beans = Bean.all
    erb :beans
  end

  get '/drinks' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    @drinks = Drink.all
    erb :drinks
  end

  get '/drink-details/:id' do
    @item = Drink.where(DrinkID: params[:id]).first

    redirect '/' unless @item
    erb :drink_details
  end

  get '/view-basket' do
    @basket_items = []
    @total = 0
    if session[:basket]
      session[:basket].each do |item_data|
        table = (item_data[:type] == 'bean') ? :Beans : :Drinks
        id_col = (item_data[:type] == 'bean') ? :BeanID : :DrinkID
        item = DB[table].where(id_col => item_data[:id]).first
        if item
          @basket_items << item
          @total += item[:Price].to_f
        end
      end
    end
    erb :view_basket
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
    session[:basket] ||= []
    session[:basket] << { id: params[:id], type: params[:type] }
    content_type :json
    { count: session[:basket].length }.to_json
    # redirect back
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