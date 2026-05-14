require_relative 'base_controller'

class AuthController < BaseController
  helpers AppHelpers
  
  get '/log-in' do
    @email = ""
    @password = ""
    erb :login_screen
  end

  post '/log-in' do
    @email = params[:email]
    @password = params[:password]
    user = DB[:Accounts].where(email: @email).first
    
    if user && BCrypt::Password.new(user[:hashed_password]) == @password
      session[:user_id] = user[:user_id]
      session[:account_type] = user[:account_type]

      if user[:suspended]
        session.clear
        @error = "Your account has been suspended. Please contact support."
        erb :login_screen
      else
        attempt_flag_account(session[:user_id])
        attempt_suspend_account(session[:user_id])

        session[:user_id] = user[:user_id]
        session[:account_type] = user[:account_type]
        
        update_recent_login(session[:user_id]) if session[:user_id]

        redirect '/'
      end

    else
      @error = "Invalid email or password"
      erb :login_screen
    end
  end

  get '/register' do
    erb :register_account
  end

  post '/register' do
    email = params[:email]
    password1 = params[:password1]
    password2 = params[:password2]
    
    # Generate Unique ID
    user_id = nil
    loop do
      user_id = rand(10000000..99999999)
      break unless Account[user_id]
    end

    # Validations
    unless str_email_address?(email)
      @error = "Invalid email format."
      return erb :register_account
    end
    unless str_uk_telephone?(params[:phone_number])
      @error = "Invalid UK phone number."
      return erb :register_account
    end
    unless password1 == password2
      @error = "Passwords do not match."
      return erb :register_account
    end
    unless str_min_length?(password1, 12)
      @error = "Password must be at least 12 characters."
      return erb :register_account
    end

    user = Account.create(
      user_id: user_id,
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: email,
      password: password1,
      phone_number: params[:phone_number],
      address: params[:address],
      postcode: params[:postcode],
      account_type: 'customer'
    )

    session[:user_id] = user.user_id
    update_recent_login(session[:user_id]) if session[:user_id]
    redirect '/'
  end

  get '/log-out' do
    session.clear  
    redirect '/log-in'
  end

  get '/forgot' do
    erb :forgot_password
  end
end
