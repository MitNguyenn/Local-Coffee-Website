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

  get '/user-tickets' do
    @live_tickets = DB[:Tickets].where(TicketResolved: false).all
    @past_tickets = DB[:Tickets].where(TicketResolved: true).all
    erb :ticket_management
  end

  get '/ticket/:id' do
    @ticket = DB[:Tickets].where(ticketID: params[:id]).first

    erb :ticket_resolve
  end

  post '/resolve-ticket/:id' do
    DB[:Tickets].where(ticketID: params[:id]).update(ticketResolved: true)

    redirect '/user-tickets'
  end

  get '/refund-tickets' do
    @tickets = DB[:Tickets].where(tickettype: "Refund").all

    erb :refund_management
  end

  get '/refund/:id' do
    @ticket = DB[:Tickets].where(ticketID: params[:id]).first

    erb :refund_resolve
  end

  post '/refund/:id' do
    DB[:Tickets].where(ticketID: params[:id]).update(ticketResolved: true)

    redirect '/refund-tickets'
  end

  get '/stock-management' do
    @beans = Bean.all
    erb :stock_management
  end
end
