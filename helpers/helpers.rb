<<<<<<< HEAD
require_relative "validation"
# require_relative "../db/databaseHelper"
=======
# ../ means "go up one folder" (out of controllers, into project)
# then we go into the helpers folder
require_relative "../helpers/validation"
require_relative "../helpers/passwordCheck"

>>>>>>> aa3f1ca66e212634a40c3342184e537d18e40b5c

# Register helpers with Sinatra
helpers do
  # This is so that we get to use the "h" method in views
  include ERB::Util

  # This is so that we include useful validation methods
  include Validation

<<<<<<< HEAD
  # This is so that we can use database helper methods
  # include DatabaseHelper

  # ... Add your own helper modules here ...

=======
  include PasswordCheck
  
>>>>>>> aa3f1ca66e212634a40c3342184e537d18e40b5c
  def current_user
    return false unless session[:user_id]
    true
    #add lookup to database here
  end
end
