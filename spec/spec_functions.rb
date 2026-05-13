require 'bcrypt'
require 'json'
require 'sequel'

def spec_before
  DatabaseManager.init_tables(DB)
end

def log_in_as(email, password)
  visit '/log-in'
  fill_in 'email', with: email
  fill_in 'password', with: password
  click_button 'Log In'
end
