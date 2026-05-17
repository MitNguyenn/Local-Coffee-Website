RSpec.describe "Account Management", type: :feature do
  let(:user_id) { 1 }

  context "Given an unauthenticated visitor" do
    context "When attempting to access account settings" do
      it "Then redirects to the login page" do
        visit "/account-settings"
        
        expect(page.current_path).to eq("/log-in")
      end
    end
  end

  context "Given a user is logged into the application" do
    before(:each) do
      log_in_as('testcust@bbc.com', 'testcust@bbc.com')
    end

    context "When visiting the account settings page" do
      it "Then shows the account settings page with user details" do
        visit "/account-settings"
        
        expect(page).to have_content("Hi, Customer")
        expect(page).to have_content("Personal Details")
      end
    end

    context "When updating account details" do
      it "Then updates the database record and redirects to home" do
        visit "/account-settings"
        fill_in "first_name", with: "Jonathan"
        click_button "Submit"

        expect(page.current_path).to eq("/")
        
        user = DB[:Accounts].where(user_id: user_id).first
        expect(user[:first_name]).to eq("Jonathan")
      end
    end

    context "When completely deleting the account" do
      it "Then purges the database record, clears session tracking, and redirects to home" do
        visit "/account-settings"
        click_button "Delete Account"

        expect(page.current_path).to eq("/")

        deleted_user = DB[:Accounts].where(user_id: user_id).first
        expect(deleted_user).to be_nil
      end
    end

    context "When visiting the loyalty card page" do
      it "Then displays the QR code and the correct stamp count" do
        DB[:Accounts].where(user_id: user_id).update(stamp_count: 5)
        visit "/loyalty-card"
        
        expect(page).to have_selector('svg')
        expect(page).to have_content("5")
      end
    end

    context "When visiting the my orders page" do
      it "Then shows current and past orders correctly" do
        visit "/my-orders"
        
        expect(page).to have_content("Latte")
        expect(page).to have_content("Arabic")
      end
    end
  end
end