require_relative 'base_controller'
require 'rqrcode'

class AccountController < BaseController
  before do
    redirect '/log-in' unless session[:UserID]
  end

  get '/account-settings' do
    @user = DB[:Accounts].where(UserID: session[:UserID]).first
    erb :account_settings
  end

  post '/update-account' do
    dob = params[:Date_of_birth] ? DateTime.parse(params[:Date_of_birth]) : nil
    DB[:Accounts].where(UserID: session[:UserID]).update(
      FirstName: params[:FirstName],
      LastName: params[:LastName],
      Postcode: params[:Postcode],
      Date_of_birth: dob
    )
    redirect '/account-settings?success=1'
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
    erb :my_orders
  end
end
