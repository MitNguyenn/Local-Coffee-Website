require_relative 'base_controller'

class ManagerController < BaseController
  before do
    redirect '/log-in' unless session[:UserID]
    unless session[:AccountType] == 'manager'
      redirect '/' 
    end
  end

  get '/staff-portal' do
    erb :staff_portal
  end

  get '/metrics' do
  @metrics = analyze_sales_data
  erb :metrics_page
  end
end
