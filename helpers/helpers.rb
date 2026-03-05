require_relative "validation"

# Register helpers with Sinatra
helpers do
  # This is so that we get to use the "h" method in views
  include ERB::Util

  # This is so that we include useful validation methods
  include Validation

  include passwordCheck
  
  def current_user
    return false unless session[:user_id]
    true
    #add lookup to database here
  end
end
