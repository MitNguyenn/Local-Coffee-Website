# Authentication and account management routes.

require 'rqrcode'

before [
  '/account-settings*', 
  '/loyalty-card*', 
  '/my-orders*', 
  '/my-favourites*', 
  '/update-account*', 
  '/delete-my-account*'
] do
  unless session[:user_id]
    redirect '/'
  end
end

get '/account-settings' do
  @user = DB[:Accounts].where(user_id: session[:user_id]).first
  @account_flagged = @user[:flagged]
  erb :account_settings
end

get '/loyalty-card' do
  @user = DB[:Accounts].where(user_id: session[:user_id]).first
  qrcode = RQRCode::QRCode.new("LoyaltyNum:#{@user[:user_id]}")
  @qr_svg = qrcode.as_svg(color: "4b2c20", module_size: 6, standalone: true, viewbox: true)
  erb :loyalty_card
end

get '/my-orders' do
  user = DB[:Accounts].where(user_id: session[:user_id]).first
  @stats = {
    'stamp_count' => user[:stamp_count] || 0,
    'until_next_discount' => 10 - (user[:stamp_count] || 0),
    'total_num_coffee' => 0, 
    'total_num_beans' => 0
  }
  @current_orders = fetch_current_orders(session[:user_id])
  @past_orders = fetch_past_orders(session[:user_id])
  @order_stats = get_stats(session[:user_id])
  erb :my_orders
end

get '/my-favourites' do
  DB[:FavouriteBeans].where(user_id: session[:user_id], pack_weight: nil).delete
  DB[:FavouriteBeans].where(user_id: session[:user_id], roast_level: nil).delete
  @beans_by_origin = DB[:Beans].all.each_with_object({}) do |bean, beans|
    beans[bean[:origin]] = bean
  end
  @pack_multipliers = DB[:BeansPackWeightPriceMarkupMultipliers].to_hash(:pack_weight, :markup_multiplier)
  @favourites = DB[:FavouriteBeans].where(user_id: session[:user_id]).all.select do |fav|
    @beans_by_origin[fav[:origin]] && @pack_multipliers[fav[:pack_weight]]
  end
  erb :my_favourites
end

post '/update-account' do
  existing = DB[:Accounts].where(email: params[:email]).exclude(user_id: session[:user_id]).first
  redirect '/account-settings?error=email_taken' if existing
  
  DB[:Accounts].where(user_id: session[:user_id]).update(
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    address: params[:address],
    postcode: params[:postcode]
  )

  redirect '/account-settings?success=true'
end

post '/delete-my-account' do
  if session[:user_id]
    DB[:Accounts].where(user_id: session[:user_id]).delete
    
    session.clear
  end
  
  redirect '/'
end