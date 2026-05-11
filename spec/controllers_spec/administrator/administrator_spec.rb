require 'spec_helper'

RSpec.describe "Admin Management", type: :feature do
  let(:admin_id)    { 99999999 }
  let(:manager_id)  { 88888888 }
  let(:barista_id)  { 77777777 }
  let(:customer_id) { 10000001 }

  describe "Access Control" do
    it "redirects unauthorized users to home" do
      visit "/staff-portal"
      expect(page.current_path).to eq("/")
    end
  end

  context "when logged in as administrator" do
    before do
      visit '/log-in'
      fill_in 'email', with: 'admin@coffee.com'
      fill_in 'password', with: 'SecretPassword123'
      click_button 'Log In'
    end

    describe "Staff Portal" do
      it "allows access to the staff dashboard" do
        visit "/staff-portal"
        expect(page).to have_content("Staff Portal")
      end
    end

    describe "Account Management" do
      it "displays all seeded accounts in the table" do
        visit "/manage-accounts"
        within("#accountsTable") do
          expect(page).to have_content("John Doe")
          expect(page).to have_content("Manager User")
          expect(page).to have_content("Barista User")
        end
      end

      it "can filter the table using the search input", js: true do
        visit "/manage-accounts"
        fill_in "accountSearch", with: "Manager"
        
        # Checking visibility based on your filterTable() logic
        expect(page).to have_content("Manager User")
        expect(page).not_to have_content("John Doe")
      end

      it "navigates to the edit page for a specific user" do
        visit "/manage-accounts"
        # Find the specific row for the customer and click Edit
        within(".acc-view__row", text: "john@example.com") do
          click_link "Edit Account"
        end
        expect(page.current_path).to eq("/edit-account/#{customer_id}")
      end

      it "updates user details and resets password" do
        visit "/edit-account/#{customer_id}"
        fill_in "first_name", with: "Johnny"
        check "reset_password" 
        click_button "Update Account"

        expect(page.current_path).to eq("/manage-accounts")
        
        user = DB[:Accounts].where(UserID: customer_id).first
        expect(user[:first_name]).to eq("Johnny")
        # Matches 'hashed_password' column from spec_functions.rb
        expect(BCrypt::Password.new(user[:hashed_password])).to eq("password123")
      end
    end

    describe "Suspensions and Flagging" do
      it "suspends a flagged account from the flagged view" do
        DB[:Accounts].where(UserID: barista_id).update(Flagged: true)
        
        visit "/flagged-accounts"
        within(".flagged-account", text: "Barista User") do
          click_link "Suspend Account"
        end

        expect(page.current_path).to eq("/flagged-accounts")
        expect(DB[:Accounts].where(UserID: barista_id).get(:Suspended)).to be true
      end
    end

    describe "Loyalty and Metrics" do
      it "manages loyalty cards" do
        visit "/manage-loyalty-cards"
        expect(page).to have_content("John Doe")
      end

      it "displays the sales metrics page" do
        visit "/metrics"
        expect(page).to have_content("Sales Metrics")
        # 7.0 is from your seeded order
        expect(page).to have_content("7.0") 
      end
    end

    describe "Document Generation" do
      it "generates a shipping label PDF" do
        order_id = DB[:Orders].where(UserID: customer_id).get(:OrderID)
        visit "/generate-label/#{order_id}"
        
        expect(page.response_headers['Content-Type']).to eq('application/pdf')
        expect(page.response_headers['Content-Disposition']).to include("Label_#{order_id}.pdf")
      end
    end
  end
end
