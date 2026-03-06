
# ../ means "go up one folder" (out of controllers, into project)
# then we go into the helpers folder
require_relative "../helpers/validation"
require_relative "../helpers/passwordCheck"


# Register helpers with Sinatra
helpers do
  # This is so that we get to use the "h" method in views
  include ERB::Util

  # This is so that we include useful validation methods
  include Validation

  # This is so that we can use database helper methods
  # include DatabaseHelper

  # ... Add your own helper modules here ...

  include PasswordCheck
  
  def current_user
    # returns nil if nobody is logged in
    return nil unless session[:user_id]
    
    # memoizing the result so the db isn't queried everytime
    @current_user ||= DB[:Accounts].where(UserID: session[:user_id]).first
  end

  def logged_in?
    !!current_user
  end
end
