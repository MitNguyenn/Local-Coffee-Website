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

    get '/manage-discounts' do
    @discounts = get_current_discounts
    erb :manage_discounts
  end

  post '/update-discount' do
    new_data = {
      discount_id:   params[:discount_id],
      discount_name: params[:discount_name],
      discount_mult: params[:discount_mult]
    }

    update_discount(new_data)
    redirect '/manage-discounts'
  end

  post '/create-discount' do
    create_discount(params[:discount_name], params[:discount_mult])
    
    redirect '/manage-discounts'
  end

  post '/delete-discount' do
    delete_discount(params[:discount_id])
    redirect '/manage-discounts'
  end

end
