require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Registration Process', type: :feature do

  context "Given an anonymous visitor wants to sign up" do
    context "When navigating directly to the signup path" do
      it "Then opens the registration form successfully" do
        visit "/register"
        expect(current_path).to eq("/register")
      end
    end
  end

  context "Given a user is on the registration page" do
    before(:each) do
      visit '/register'
    end

    context "When all valid registration details are submitted" do
      it "Then registers the account successfully and redirects to home" do
        fill_in 'first_name', with: 'John'
        fill_in 'last_name', with: 'Doe'
        fill_in 'email', with: 'john123@example.com'
        fill_in 'password1', with: 'SecretPassword123'
        fill_in 'password2', with: 'SecretPassword123'
        fill_in 'phone_number', with: '07123456789'
        fill_in 'address', with: '123 Ruby Lane'
        fill_in 'postcode', with: 'SW1A 1AA'
        click_button 'Register' 

        expect(current_path).to eq('/')
        
        user = DB[:Accounts].where(Email: 'john123@example.com').first
        expect(user).not_to be_nil
      end
    end

    context "When password fields do not match" do
      it "Then stays on registration page and displays a mismatch error" do
        fill_in 'first_name', with: 'John'
        fill_in 'last_name', with: 'Doe'
        fill_in 'email', with: 'john123@example.com'
        fill_in 'password1', with: 'SecretPassword123'
        fill_in 'password2', with: 'WrongPassword123'
        fill_in 'phone_number', with: '07123456789'
        fill_in 'address', with: '123 Ruby Lane'
        fill_in 'postcode', with: 'SW1A 1AA'
        click_button 'Register' 

        expect(current_path).to eq('/register')
        expect(page).to have_content("Passwords do not match.")
      end
    end

    context "When the provided password is too short" do
      it "Then stays on registration page and displays a length requirement error" do
        fill_in 'first_name', with: 'John'
        fill_in 'last_name', with: 'Doe'
        fill_in 'email', with: 'john123@example.com'
        fill_in 'password1', with: 'short'
        fill_in 'password2', with: 'short'
        fill_in 'phone_number', with: '07123456789'
        fill_in 'address', with: '123 Ruby Lane'
        fill_in 'postcode', with: 'SW1A 1AA'
        click_button 'Register' 

        expect(current_path).to eq('/register')
        expect(page).to have_content("Password must be at least 12 characters.")
      end
    end

    context "When an invalid email format is entered" do
      it "Then stays on registration page and displays an invalid email error" do
        fill_in 'first_name', with: 'John'
        fill_in 'last_name', with: 'Doe'
        fill_in 'email', with: 'wrong'
        fill_in 'password1', with: 'SecretPassword123'
        fill_in 'password2', with: 'SecretPassword123'
        fill_in 'phone_number', with: '07123456789'
        fill_in 'address', with: '123 Ruby Lane'
        fill_in 'postcode', with: 'SW1A 1AA'
        click_button 'Register' 

        expect(current_path).to eq('/register')
        expect(page).to have_content("Invalid email format.")
      end
    end

    context "When an invalid UK phone number format is entered" do
      it "Then stays on registration page and displays a phone format error" do
        fill_in 'first_name', with: 'John'
        fill_in 'last_name', with: 'Doe'
        fill_in 'email', with: 'john123@example.com'
        fill_in 'password1', with: 'SecretPassword123'
        fill_in 'password2', with: 'SecretPassword123'
        fill_in 'phone_number', with: '123'
        fill_in 'address', with: '123 Ruby Lane'
        fill_in 'postcode', with: 'SW1A 1AA'
        click_button 'Register' 

        expect(current_path).to eq('/register')
        expect(page).to have_content("Invalid UK phone number.")
      end
    end
  end
end