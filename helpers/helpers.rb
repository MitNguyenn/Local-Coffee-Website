require_relative "validation"
require_relative "../db/database_helper"

# Register helpers with Sinatra
helpers do
  # This is so that we get to use the "h" method in views
  include ERB::Util

  # This is so that we include useful validation methods
  include Validation

  # This is so that we can use database helper methods
  include DatabaseHelper

  # ... Add your own helper modules here ...
end
