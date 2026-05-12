require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Registration Process', type: :feature do

  it 'allows a new user to register successfully' do
    visit '/register'
    
    fill_in 'first_name', with: 'John'
    fill_in 'last_name', with: 'Doe'
    fill_in 'email', with: 'john123@example.com'
    fill_in 'password1', with: '_p_'
    fill_in 'password2', with: '_p_'
    fill_in 'PhoneNumber', with: '07123456789'
    fill_in 'Address', with: '123 Ruby Lane'
    fill_in 'postcode', with: 'SW1A 1AA'
    
    click_button 'Register' 

    expect(current_path).to eq('/')
  end


  it 'shows an error when passwords do not match' do
    visit '/register'
    
    fill_in 'password1', with: '_p_'
    fill_in 'password2', with: 'WrongPassword123'
    
    click_button 'Register'

    expect(page).to have_content('Passwords do not match.')
  end
end
