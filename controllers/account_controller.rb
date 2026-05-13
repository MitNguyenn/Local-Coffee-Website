require_relative 'base_controller'
require 'rqrcode'

class AccountController < BaseController
  helpers AppHelpers
  before do
    redirect '/' unless session[:user_id]
  end

  get '/account-settings' do
    @user = DB[:Accounts].where(user_id: session[:user_id]).first
    @account_flagged = @user[:flagged]
    erb :account_settings
  end

  post '/update-account' do
    DB[:Accounts].where(user_id: session[:user_id]).update(
      first_name: params[:first_name],
      last_name: params[:last_name],
      postcode: params[:postcode],
    )
    redirect '/'
  end

  get '/loyalty-card' do
    @user = DB[:Accounts].where(user_id: session[:user_id]).first
    if @user
      qrcode = RQRCode::QRCode.new("LoyaltyNum:#{@user[:user_id]}")
      @qr_svg = qrcode.as_svg(color: "4b2c20", module_size: 6, standalone: true, viewbox: true)
      erb :loyalty_card
    else
      "Error: Account not found."
    end
  end

  get '/my-orders' do\
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
end
