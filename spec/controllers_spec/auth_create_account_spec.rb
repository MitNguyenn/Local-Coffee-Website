require 'spec_helper'
require 'bcrypt'
require 'sequel'

RSpec.describe 'Registration Process', type: :feature do
  
  it 'allows a new user to register successfully' do
    visit '/register'
    
    fill_in 'first_name', with: 'John'
    fill_in 'last_name', with: 'Doe'
    fill_in 'email', with: 'john@example.com'
    fill_in 'PhoneNumber', with: '07123456789' # Valid UK number
    fill_in 'Address', with: '123 Ruby Lane'
    fill_in 'postcode', with: 'SW1A 1AA'
    fill_in 'password1', with: 'SecretPassword123'
    fill_in 'password2', with: 'SecretPassword123'
    
    click_button 'Register' 

    # Verify redirection to home and session creation
    expect(current_path).to eq('/')
    
    #check db
    user = Account.first(email: 'john@example.com')
    expect(user).not_to be_nil
    expect(user.first_name).to eq('John')
    expect(user.last_name).to eq('Doe')
    expect(user.PhoneNumber).to eq('07123456789')
    expect(user.Address).to eq('123 Ruby Lane')
    expect(user.Postcode).to eq('SW1A 1AA')
    expect(user.AccountType).to eq('customer')
    expect(user.password).to eq(BCrypt::Password.create('SecretPassword123'))
  end

  it 'shows an error when passwords do not match' do
    visit '/register'
    
    fill_in 'first_name', with: 'John'
    fill_in 'last_name', with: 'Doe'
    fill_in 'email', with: 'john@example.com'
    fill_in 'PhoneNumber', with: '07123456789' # Valid UK number
    fill_in 'Address', with: '123 Ruby Lane'
    fill_in 'postcode', with: 'SW1A 1AA'
    fill_in 'password1', with: 'SecretPassword123'
    fill_in 'password2', with: 'WrongPassword123'
    
    click_button 'Register'

    expect(page).to have_content('Passwords do not match.')
    expect(current_path).to eq('/register')
  end

  it 'shows an error for invalid email format' do
    visit '/register'
    
    fill_in 'first_name', with: 'John'
    fill_in 'last_name', with: 'Doe'
    fill_in 'email', with: 'wrongemailformat' # Invalid email
    fill_in 'PhoneNumber', with: '07123456789' # Valid UK number
    fill_in 'Address', with: '123 Ruby Lane'
    fill_in 'postcode', with: 'SW1A 1AA'
    fill_in 'password1', with: 'SecretPassword123'
    fill_in 'password2', with: 'SecretPassword123'
    
    click_button 'Register' 

    expect(page).to have_content('Invalid email format.')
    expect(current_path).to eq('/register')
  end

  it 'shows an error for invalid UK phone number' do
    visit '/register'

    fill_in 'first_name', with: 'John'
    fill_in 'last_name', with: 'Doe'
    fill_in 'email', with: 'john@example.com'
    fill_in 'PhoneNumber', with: '12345' # Invalid UK number
    fill_in 'Address', with: '123 Ruby Lane'
    fill_in 'postcode', with: 'SW1A 1AA'
    fill_in 'password1', with: 'SecretPassword123'
    fill_in 'password2', with: 'SecretPassword123'
    
    click_button 'Register' 

    expect(page).to have_content('Invalid phone number format.')
    expect(current_path).to eq('/register')
  end

  it 'shows an error for short passwords' do
    visit '/register'

    fill_in 'first_name', with: 'John'
    fill_in 'last_name', with: 'Doe'
    fill_in 'email', with: 'jhon@example.com'
    fill_in 'PhoneNumber', with: '07123456789' # Valid UK number
    fill_in 'Address', with: '123 Ruby Lane'
    fill_in 'postcode', with: 'SW1A 1AA'
    fill_in 'password1', with: 'short' # Too short
    fill_in 'password2', with: 'short' # Too short

    click_button 'Register'

    expect(page).to have_content('Password must be at least 12 characters.')
    expect(current_path).to eq('/register')
  end
end
