require_relative 'base_controller'

class ManagerController < BaseController
  before do
    unless session[:UserID] && session[:AccountType] == 'manager' || session[:AccountType] == 'administrator'
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
end
