require_relative 'base_controller'

class ManagerController < BaseController
  before do
    unless session[:user_id] && session[:account_type] == 'manager' || session[:account_type] == 'administrator'
      redirect '/'
    end
  end

  get '/metrics' do
    @metrics = analyze_sales_data
    erb :metrics_page
  end
  
  get '/stock-management' do
    @beans = Bean.all
    erb :stock_management
  end

  get '/manage-discounts' do
    @discounts = get_current_discounts
    erb :manage_discounts
  end

  post '/update-discount' do
    new_data = {
      discount_id:   params[:discount_id],
      discount_name: params[:discount_name],
      discount_mult: params[:discount_mult]
    }

    update_discount(new_data)
    redirect '/manage-discounts'
  end

  post '/create-discount' do
    create_discount(params[:discount_name], params[:discount_mult])
    
    redirect '/manage-discounts'
  end

  post '/delete-discount' do
    delete_discount(params[:discount_id])
    redirect '/manage-discounts'
  end

  get '/edit-drink-details' do
    @drinks = Drink.all
    erb :edit_drink_details
  end

  post '/update-drink-details' do
    new_prices = params[:prices]
    @drinks = Drink.all
    
    @drinks.each_with_index do |drink, i|
      drink.update(regular_price: new_prices[i].to_f)
    end
    redirect '/edit-drink-details'
  end

end
