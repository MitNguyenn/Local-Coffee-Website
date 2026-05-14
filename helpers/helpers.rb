
require_relative "../helpers/validation"
require_relative "../helpers/passwordCheck"
require_relative "../helpers/analyzeData"
require_relative "../helpers/myOrders"


module AppHelpers
  include ERB::Util

  include Validation

  include AnalyzeData

  include PasswordCheck
  include MyOrders

  include AccountRecency

  include Discounts
  
  include GetBeans
  
  def current_user

    return nil unless session[:user_id]
    

    @current_user ||= DB[:Accounts].where(user_id: session[:user_id]).first
  end

  def update_recent_login(user_id)
    DB[:Accounts].where(user_id: user_id).update(recent_login: Time.now)
  end

  def logged_in?
    !!current_user
  end
end
