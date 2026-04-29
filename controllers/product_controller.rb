require_relative 'base_controller'

class ProductController < BaseController
  helpers AppHelpers
  get '/coffee-beans' do
    @beans = Bean.all
    erb :beans
  end

  get '/drinks' do
    @drinks = Drink.all
    erb :drinks
  end

  get '/product/' do
    @type = params[:type]
    id = [params[:id]]

    if @type == 'bean'
      @item = Bean[id]
      @template = :bean_details
    elsif @type == 'drink'
      @item = Drink[id]
      @template = :drink_details
    else 
      halt 404, "Product type not found."
    end
    erb @template
  end

  get '/view-basket' do
    @basket_items = []
    @total = 0
    if session[:basket]
      session[:basket].each do |item_data|
        item = item_data[:type] == 'bean' ? Bean[item_data[:id]] : Drink[item_data[:id]]
        if item
          @basket_items << item
          @total += item[:Price] 
        end
      end
    end
    erb :view_basket
  end

  post '/place-order' do
  redirect '/log-in' unless logged_in?
  
  total = calculate_basket_total(session[:basket]) 
  
  order = Order.create(
    UserID: session[:UserID],
    OrderDate: Time.now,
    TotalAmount: total,
    Status: 'Processing'
  )
  
  session[:basket].each do |item_data|
    OrderItem.create(
      OrderID: order.OrderID,
      ProductID: item_data[:id],
      ProductType: item_data[:type]
    )
  end
  
  session[:basket] = []
  redirect '/order-success'
end

  post '/add-to-basket' do
    session[:basket] ||= []
    session[:basket] << { id: params[:id], type: params[:type] }
    redirect '/coffee-beans'
  end

  get '/checkout' do
  @subtotal = 0
  @basket_items = []

  if session[:basket]
    session[:basket].each do |item_data|
      # item_data looks like { id: "1", type: "bean" }
      id = item_data[:id]
      type = item_data[:type]

      # Find the item in the correct table
      item = (type == 'bean') ? Bean[id] : Drink[id]

      if item
        @basket_items << item
        @subtotal += item[:Price] # Ensure :Price matches your DB column name
      end
    end
  end
  
  @user = Account[session[:UserID]] if logged_in?
  erb :checkout
end
end
