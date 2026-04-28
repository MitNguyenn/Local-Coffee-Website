require_relative 'base_controller'

class ProductController < BaseController
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

  post '/add-to-basket' do
    session[:basket] ||= []
    session[:basket] << { id: params[:id], type: params[:type] }
    redirect '/coffee-beans'
  end
end
