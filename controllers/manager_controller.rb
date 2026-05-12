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

  get '/user-tickets' do
    update_recent_login(session[:UserID]) if session[:UserID]
    @live_tickets = DB[:Tickets].where(TicketResolved: false).all
    @past_tickets = DB[:Tickets].where(TicketResolved: true).all
    erb :ticket_management
  end

  get '/stock-management' do
    @beans = Bean.all
    erb :stock_management
  end
end
