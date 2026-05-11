require_relative 'base_controller'

class ManagerController < BaseController
  before do
  if !session[:UserID] || !['manager', 'administrator'].include?(session[:AccountType].to_s.downcase)
    redirect '/'
  end
end

  get '/staff-portal' do
    update_recent_login(session[:UserID]) if session[:UserID]
    erb :staff_portal
  end

  get '/metrics' do
    update_recent_login(session[:UserID]) if session[:UserID]
    @metrics = analyze_sales_data
    erb :metrics_page
  end
end
