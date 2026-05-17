# User Log In Spec file.

require 'spec_helper'

RSpec.describe 'Authentication process', type: :feature do

  context "Given a user wants to log in" do
    context "When valid credentials are provided" do
      it "Then authenticates successfully and redirects to home" do
        log_in_as('testcust@bbc.com', 'testcust@bbc.com')

        expect(current_path).to eq('/')
        expect(page).to have_content('Log out')
      end
    end

    context "When wrong credentials are provided" do
      it "Then displays a login error message and keeps them on the login page" do
        log_in_as('testcust@bbc.com', 'password124')                       

        expect(page).to have_content('Log in')
        expect(current_path).to eq('/log-in')
      end
    end

    context "When the account is suspended" do
      it "Then blocks the authentication request and shows a suspension message" do
        log_in_as('testsuspended@bbc.com', 'testpass')

        expect(page).to have_content('Your account has been suspended. Please contact support.')
        expect(current_path).to eq('/log-in')
      end
    end
  end

  context "Given a user is logged into the application" do
    before(:each) do
      log_in_as('testcust@bbc.com', 'testcust@bbc.com')
    end

    context "When the logout action is executed" do
      it "Then terminates the session and returns to an unauthenticated state" do
        visit '/log-out'
        
        expect(page).to have_content('Log in')
      end
    end

    context "When attempting to navigate to the forgot password page" do
      it "Then displays the forgot password workspace successfully" do
        visit '/forgot'

        expect(current_path).to eq('/forgot')
        expect(page).to have_content("Forgot Password")
      end
    end
  end
end