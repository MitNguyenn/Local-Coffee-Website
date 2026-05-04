require_relative 'base_controller'

class ManagerController < BaseController
  before do
    authorized_roles = ['manager', 'administrator']
    
    current_role = session[:AccountType].to_s.downcase
  
    unless session[:UserID] && authorized_roles.include?(current_role)
      redirect '/'
    end
  end

  get '/staff-portal' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    erb :staff_portal
  end

  get '/metrics' do
    update_Recet_Login(session[:UserID]) if session[:UserID]
    @metrics = analyze_sales_data
    erb :metrics_page
  end
end
