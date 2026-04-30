# ../ means "go up one folder" (out of controllers, into project)
# then we go into the helpers folder
require_relative "../helpers/validation"
require_relative "../helpers/passwordCheck"
require_relative "../helpers/analyzeData"
require_relative "../helpers/myOrders"


# Register helpers with Sinatra
module AppHelpers
  include ERB::Util

  include Validation

  include AnalyzeData


  include PasswordCheck
  include MyOrders
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
