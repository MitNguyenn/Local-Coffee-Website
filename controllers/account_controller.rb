require_relative 'base_controller'
require 'rqrcode'

class AccountController < BaseController
  helpers AppHelpers
  before do
    redirect '/' unless session[:UserID]
  end

  get '/account-settings' do
    @user = DB[:Accounts].where(UserID: session[:UserID]).first
    @account_flagged = @user[:Flagged]
    erb :account_settings
  end

  post '/update-account' do
    DB[:Accounts].where(UserID: session[:UserID]).update(
      first_name: params[:first_name],
      last_name: params[:last_name],
      Postcode: params[:Postcode],
    )
    redirect '/'
  end

  get '/loyalty-card' do
    @user = DB[:Accounts].where(UserID: session[:UserID]).first
    if @user
      qrcode = RQRCode::QRCode.new("LoyaltyNum:#{@user[:UserID]}")
      @qr_svg = qrcode.as_svg(color: "4b2c20", module_size: 6, standalone: true, viewbox: true)
      erb :loyalty_card
    else
      "Error: Account not found."
    end
  end

  get '/my-orders' do
    @current_orders = fetch_current_orders(session[:UserID])
    @past_orders = fetch_past_orders(session[:UserID])
    @order_stats = get_stats(session[:UserID])
    erb :my_orders
  end
end
