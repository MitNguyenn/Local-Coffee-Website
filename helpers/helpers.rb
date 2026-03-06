
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
    return false unless session[:user_id]
    true
    #add lookup to database here
  end
end
