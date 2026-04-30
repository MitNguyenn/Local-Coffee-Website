require_relative 'base_controller'

class ManagerController < BaseController
  redirect '/' if !logged_in? || session[:account_type] != 'manager'

  get '/staff-portal' do
    erb :staff_portal
  end

  get '/metrics' do
  @metrics = analyze_sales_data
  erb :metrics_page
  end
end
