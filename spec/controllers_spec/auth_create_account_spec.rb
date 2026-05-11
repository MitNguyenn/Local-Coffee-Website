require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Registration Process', type: :feature do
  
  it 'allows a new user to register successfully' do
    visit '/register'
    
    # Use the text inside the <label> tags
    fill_in 'First Name', with: 'John'
    fill_in 'Last Name', with: 'Doe'
    fill_in 'Email', with: 'john@example.com'
    fill_in 'Password', with: 'SecretPassword123', match: :prefer_exact
    fill_in 'Retype password', with: 'SecretPassword123'
    fill_in 'Phone Number', with: '07123456789'
    fill_in 'Address', with: '123 Ruby Lane'
    fill_in 'Postcode', with: 'SW1A 1AA'
    
    click_button 'Register' 

    expect(current_path).to eq('/')
    
  end

  it 'shows an error when passwords do not match' do
    visit '/register'
    
    fill_in 'password1', with: 'SecretPassword123'
    fill_in 'password2', with: 'WrongPassword123'
    
    click_button 'Register'

    expect(page).to have_content('Passwords do not match.')
  end
end
