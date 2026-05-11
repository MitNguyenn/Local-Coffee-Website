
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
  def current_user

    return nil unless session[:UserID]
    

    @current_user ||= DB[:Accounts].where(UserID: session[:UserID]).first
  end

  def update_Recet_Login(user_id)
    DB[:Accounts].where(UserID: user_id).update(Recent_Login: Time.now)
  end

  def logged_in?
    !!current_user
  end
end
