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
    
    if user && BCrypt::Password.new(user[:hashedPassword]) == @password
      session[:UserID] = user[:UserID]
      session[:AccountType] = user[:AccountType]

      attempt_flag_account(session[:UserID])
      attempt_suspend_account(session[:UserID])

      if user[:Suspended]
        session.clear
        @error = "Your account has been suspended. Please contact support."
        return erb :login_screen
      end

      session[:UserID] = user[:UserID]
      session[:AccountType] = user[:AccountType]
      
      update_recent_login(session[:UserID]) if session[:UserID]

      redirect '/'

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
    UserID = nil
    loop do
      UserID = rand(10000000..99999999)
      break unless Account[UserID]
    end

    # Validations
    unless str_email_address?(email)
      @error = "Invalid email format."
      return erb :register_account
    end
    unless str_uk_telephone?(params[:PhoneNumber])
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
      UserID: UserID,
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: email,
      password: password1,
      PhoneNumber: params[:PhoneNumber],
      Address: params[:Address],
      Postcode: params[:postcode],
      AccountType: 'customer'
    )

    session[:UserID] = user.UserID
    update_recent_login(session[:UserID]) if session[:UserID]
    redirect '/'
  rescue => e
    @error = "Registration failed: #{e.message}"
    erb :register_account
  end

  get '/log-out' do
    session.clear  
    redirect '/log-in'
  end

  get '/forgot' do
    erb :forgot_password
  end
end
