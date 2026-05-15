# ==============================================================================
# MANAGEMENT SPACE GUARDIAN (TARGETED REGEX FILTER)
# ==============================================================================
before %r{/(metrics|bean-stock-management|bean-update|update-bean-stock|manage-discounts|update-discount|create-discount|delete-discount|edit-drink-details|update-drink-details)} do
  unless session[:user_id] && (session[:account_type] == 'manager' || session[:account_type] == 'administrator')
    redirect '/'
  end
end

# ==============================================================================
# GET ROUTING ENGINE
# ==============================================================================

get '/metrics' do
  @metrics = analyze_sales_data
  erb :metrics_page
end

get '/bean-stock-management' do
  @current_bean_stock = get_bean_stock()
  erb :bean_stock_management
end

get '/bean-update/:origin' do
  @current_bean = get_bean_data(params[:origin])
  erb :bean_update
end

get '/manage-discounts' do
  @discounts = get_current_discounts
  erb :manage_discounts
end

get '/edit-drink-details' do
  @drinks = Drink.all
  erb :edit_drink_details
end

# ==============================================================================
# POST ROUTING ENGINE
# ==============================================================================

post '/update-bean-stock/:origin' do
  new_data = {
    new_origin: params[:new_origin],
    new_stock: params[:new_stock].to_f,
    new_price_per_250g: params[:new_price_per_250g].to_f
  }
  
  update_bean_stock(params[:origin], new_data)
  redirect '/bean-stock-management'
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

post '/update-drink-details' do
  new_prices = params[:prices]
  @drinks = Drink.all
  
  @drinks.each_with_index do |drink, i|
    drink.update(regular_price: new_prices[i].to_f)
  end
  redirect '/edit-drink-details'
end