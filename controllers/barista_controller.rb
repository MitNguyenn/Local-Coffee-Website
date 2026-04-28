require_relative 'base_controller'

class BaristaController < BaseController
  get '/staff-portal' do
    erb :staff_portal
  end
end