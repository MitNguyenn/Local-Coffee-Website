
get '/' do
  update_recent_login(session[:user_id]) if session[:user_id]
  erb :home
end

get '/help' do
  erb :help
end

get '/cart' do 
  erb :cart
end

get '/discounts' do
  @discounts = get_current_discounts()
  erb :discounts_page
end


post '/help' do
  userid = DB[:Accounts].where(email: params[:form_useremail]).get(:user_id)
  
  if userid.nil? || params[:form_request_description].to_s.strip.empty?
    @error = "Missing info! Please check the email and description."
    return erb :help
  end

  Ticket.create(
    user_id: userid, 
    ticket_type: params[:problem_type], 
    ticket_content: params[:form_request_description]
  )
  redirect "/"
end
