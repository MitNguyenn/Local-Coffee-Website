require_relative 'base_controller'

class ManagerController < BaseController
  before do
    unless session[:UserID] && session[:account_type] == 'manager'
      redirect '/'
    end
  end

  get '/staff-portal' do
    update_Recet_Login(session[:user_id]) if session[:user_id]
    erb :staff_portal
  end

  get '/metrics' do
    update_Recet_Login(session[:user_id]) if session[:user_id]
  @metrics = analyze_sales_data
  erb :metrics_page
  end
end
