require_relative 'base_controller'

class ManagerController < BaseController
  before do
    unless session[:UserID] && session[:AccountType] == 'manager' || session[:AccountType] == 'administrator'
      redirect '/'
    end
  end

  get '/metrics' do
    update_recent_login(session[:UserID]) if session[:UserID]
    @metrics = analyze_sales_data
    erb :metrics_page
  end

end
