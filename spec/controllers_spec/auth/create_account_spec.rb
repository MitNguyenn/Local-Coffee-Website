require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Registration Process', type: :feature do
  describe "Visit register page" do
    it "User can see page" do
      visit "/register"
      expect(current_path).to eq("/register")
    end
  end

  describe "Creating new account" do
    it 'allows a new user to register successfully' do
      visit '/register'
      
      fill_in 'first_name', with: 'John'
      fill_in 'last_name', with: 'Doe'
      fill_in 'email', with: 'john123@example.com'
      fill_in 'password1', with: 'SecretPassword123'
      fill_in 'password2', with: 'SecretPassword123'
      fill_in 'PhoneNumber', with: '07123456789'
      fill_in 'Address', with: '123 Ruby Lane'
      fill_in 'postcode', with: 'SW1A 1AA'
      
      click_button 'Register' 

      expect(current_path).to eq('/')

      #check db for account existing
    end

    it 'User inputs passwords which dont match' do
      visit '/register'
      
      fill_in 'first_name', with: 'John'
      fill_in 'last_name', with: 'Doe'
      fill_in 'email', with: 'john123@example.com'
      fill_in 'password1', with: 'SecretPassword123'
      fill_in 'password2', with: 'WrongPassword123'
      fill_in 'PhoneNumber', with: '07123456789'
      fill_in 'Address', with: '123 Ruby Lane'
      fill_in 'postcode', with: 'SW1A 1AA'
      
      click_button 'Register' 

      expect(current_path).to eq('/register')
      expect(page).to have_content("Passwords do not match.")
    end

    it 'User inputs too short of a password' do
      visit '/register'
      
      fill_in 'first_name', with: 'John'
      fill_in 'last_name', with: 'Doe'
      fill_in 'email', with: 'john123@example.com'
      fill_in 'password1', with: 'short'
      fill_in 'password2', with: 'short'
      fill_in 'PhoneNumber', with: '07123456789'
      fill_in 'Address', with: '123 Ruby Lane'
      fill_in 'postcode', with: 'SW1A 1AA'
      
      click_button 'Register' 

      expect(current_path).to eq('/register')
      expect(page).to have_content("Password must be at least 12 characters.")
    end

    it 'User inputs invalid email' do
      visit '/register'
      
      fill_in 'first_name', with: 'John'
      fill_in 'last_name', with: 'Doe'
      fill_in 'email', with: 'wrong'
      fill_in 'password1', with: 'SecretPassword123'
      fill_in 'password2', with: 'SecretPassword123'
      fill_in 'PhoneNumber', with: '07123456789'
      fill_in 'Address', with: '123 Ruby Lane'
      fill_in 'postcode', with: 'SW1A 1AA'
      
      click_button 'Register' 

      expect(current_path).to eq('/register')
      expect(page).to have_content("Invalid email format.")
    end

    it 'User inputs invalid phone number' do
      visit '/register'
      
      fill_in 'first_name', with: 'John'
      fill_in 'last_name', with: 'Doe'
      fill_in 'email', with: 'john123@example.com'
      fill_in 'password1', with: 'SecretPassword123'
      fill_in 'password2', with: 'SecretPassword123'
      fill_in 'PhoneNumber', with: '123'
      fill_in 'Address', with: '123 Ruby Lane'
      fill_in 'postcode', with: 'SW1A 1AA'
      
      click_button 'Register' 

      expect(current_path).to eq('/register')
      expect(page).to have_content("Invalid UK phone number.")
    end
  end
end
