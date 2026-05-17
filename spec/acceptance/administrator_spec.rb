require 'spec_helper'
require 'fileutils'
require 'sqlite3'

RSpec.describe "Admin Management", type: :feature do
  let(:admin_id)    { 4 }
  let(:customer_id) { 1 }
  let(:backup_dir)  { File.expand_path('../../../db/backups', __dir__) }

  before(:each) do
    FileUtils.rm_rf(backup_dir)
  end

  after(:each) do
    FileUtils.rm_rf(backup_dir)
  end

  describe "Attempts to visit pages without valid credentials" do
    it "redirects an unauthenticated user away from manage-accounts" do
      visit "/manage-accounts"
      expect(current_path).to eq("/log-in")
    end

    it "redirects an unauthenticated user away from flagged-accounts" do
      visit "/flagged-accounts"
      expect(current_path).to eq("/log-in")
    end

    it "redirects an unauthenticated user away from employee-accounts" do
      visit "/employee-accounts"
      expect(current_path).to eq("/log-in")
    end

    it "redirects an unauthenticated user away from database-status" do
      visit "/database-status"
      expect(current_path).to eq("/log-in")
    end

    it "redirects a barista away from manage-accounts" do
      log_in_as('testbarista@bbc.com', 'testbarista@bbc.com')
      visit "/manage-accounts"
      expect(current_path).to eq("/")
    end

    it "redirects a barista away from database-status" do
      log_in_as('testbarista@bbc.com', 'testbarista@bbc.com')
      visit "/database-status"
      expect(current_path).to eq("/")
    end

    it "redirects a customer away from manage-accounts" do
      log_in_as('testcust@bbc.com', 'testcust@bbc.com')
      visit "/manage-accounts"
      expect(current_path).to eq("/")
    end

    it "redirects a customer away from database-status" do
      log_in_as('testcust@bbc.com', 'testcust@bbc.com')
      visit "/database-status"
      expect(current_path).to eq("/")
    end
  end

  context "Logged in as administrator" do
    before(:each) do
      log_in_as('testadmin@bbc.com', 'testadmin@bbc.com')
    end

    describe "Admin visits all pages" do
      it "can access the manage-accounts page" do
        visit "/manage-accounts"
        expect(current_path).to eq("/manage-accounts")
      end

      it "can access the flagged-accounts page" do
        visit "/flagged-accounts"
        expect(current_path).to eq("/flagged-accounts")
      end

      it "can access the order-management page" do
        visit "/order-management/administrator"
        expect(current_path).to eq("/order-management/administrator")
      end

      it "can access the employee-accounts page" do
        visit "/employee-accounts"
        expect(current_path).to eq("/employee-accounts")
      end

      it "can access the database-status panel" do
        visit "/database-status"
        expect(current_path).to eq("/database-status")
      end
    end

    describe "Database Control Panel Interface (GET & POST)" do
      it "loads the layout container and handles empty directories cleanly" do
        visit "/database-status"
        expect(page).to have_selector("#db-status-dashboard-panel")
        expect(page).to have_content("No active save point archives found on disk.")
      end

      it "exposes a link pointing back to master account administration" do
        visit "/database-status"
        click_link "Return to Admin Dashboard"
        expect(current_path).to eq("/manage-accounts")
      end

      it "renders attributes of existing file saves dynamically" do
        FileUtils.mkdir_p(backup_dir)
        test_file = File.join(backup_dir, "backup_20260514_120000.sqlite3")
        File.write(test_file, "mock data payload string structure footprint")

        visit "/database-status"
        expect(page).to have_content("backup_20260514_120000.sqlite3")
        expect(page).to have_content("0.04 KB")
      end
  
    end

    describe "Account Management Table Interface" do
      it "displays all seeded accounts with correct IDs" do
        visit "/manage-accounts"
        expect(page).to have_content("1")
        expect(page).to have_content("Customer")
        expect(page).to have_content("Test")
      end

      it "has a functional search input field" do
        visit "/manage-accounts"
        expect(page).to have_field("accountSearch")
      end

      it "navigates to the edit page via the table button" do
        visit "/manage-accounts"
        within(".acc-view__row", text: "testcust@bbc.com") do
          click_link "Edit Account"
        end
        expect(current_path).to eq("/edit-account/1")
      end
    end

    describe "Edit Account Interface Elements" do
      it "renders the edit form pre-populated with the account's data" do
        visit "/edit-account/#{customer_id}"
        expect(find_field("first_name").value).to eq("Customer")
        expect(find_field("last_name").value).to  eq("Test")
        expect(find_field("email").value).to       eq("testcust@bbc.com")
      end

      it "updates first name, last name, phone, postcode, and redirects to manage-accounts" do
        visit "/edit-account/#{customer_id}"
        fill_in "first_name",   with: "Jane"
        fill_in "last_name",    with: "Smith"
        fill_in "phone_number", with: "07111222333"
        fill_in "postcode",     with: "S10 2TN"
        click_button "Save Changes"
        expect(current_path).to eq("/manage-accounts")

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(account[:first_name]).to   eq("Jane")
        expect(account[:last_name]).to    eq("Smith")
        expect(account[:phone_number]).to eq("07111222333")
        expect(account[:postcode]).to     eq("S10 2TN")
      end

      it "updates the email address" do
        visit "/edit-account/#{customer_id}"
        fill_in "email", with: "newemail@example.com"
        click_button "Save Changes"

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(account[:email]).to eq("newemail@example.com")
      end

      it "updates the account type" do
        visit "/edit-account/#{customer_id}"
        select "Barista", from: "account_type"
        click_button "Save Changes"

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(account[:account_type]).to eq("barista")
      end

      it "resets the password to 'password123' when the reset checkbox is ticked" do
        visit "/edit-account/#{customer_id}"
        check "reset_password"
        click_button "Save Changes"

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(BCrypt::Password.new(account[:hashed_password])).to eq("password123")
      end

      it "does not change the password when reset checkbox is not ticked" do
        original_hash = DB[:Accounts].where(user_id: customer_id).get(:hashed_password)

        visit "/edit-account/#{customer_id}"
        uncheck "reset_password"
        click_button "Save Changes"

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(account[:hashed_password]).to eq(original_hash)
      end
    end
    
    describe "Flagged Accounts Handling" do
      before do
        DB[:Accounts].where(user_id: customer_id).update(flagged: true, flagged_at: Time.now)
      end

      it "displays accounts that are flagged" do
        visit "/flagged-accounts"
        expect(page).to have_content("testcust@bbc.com")
      end

      it "does not display unflagged accounts" do
        visit "/flagged-accounts"
        expect(page).not_to have_content("testadmin@bbc.com")
      end

      it "suspends an account and redirects to flagged-accounts" do
        visit "/suspend-account/#{customer_id}"
        expect(current_path).to eq("/flagged-accounts")

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(account[:suspended]).to be_truthy
      end

      it "does not suspend an already-clean account unintentionally" do
        DB[:Accounts].where(user_id: admin_id).update(suspended: false)
        visit "/flagged-accounts"
        account = DB[:Accounts].where(user_id: admin_id).first
        expect(account[:suspended]).to be_falsy
      end
    end

    describe "Employee Accounts Management" do
      it "displays categorized groups of employee accounts" do
        visit "/employee-accounts"
        expect(page).to have_content("testbarista@bbc.com")
        expect(page).to have_content("testmanager@bbc.com")
        expect(page).to have_content("testadmin@bbc.com")
      end

      it "deletes an employee account successfully via post form action" do
        visit "/employee-accounts"
        
        within(".acc-view__row", text: "testbarista@bbc.com") do
          click_button "Delete"
        end

        expect(current_path).to eq("/employee-accounts")
        expect(page).not_to have_content("testbarista@bbc.com")
        expect(DB[:Accounts].where(user_id: 2).first).to be_nil
      end
    end

    describe "Order Management Subsystem" do
      it "displays the completed orders tracking frame" do
        visit "/order-management/administrator"
        expect(page).to have_content("Paid")
      end
    end
  end
end