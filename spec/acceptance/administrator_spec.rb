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

  context "Given an unauthenticated visitor" do
    context "When attempting to access the manage accounts endpoint" do
      it "Then redirects to the login screen" do
        visit "/manage-accounts"
        expect(current_path).to eq("/log-in")
      end
    end

    context "When attempting to access the flagged accounts endpoint" do
      it "Then redirects to the login screen" do
        visit "/flagged-accounts"
        expect(current_path).to eq("/log-in")
      end
    end

    context "When attempting to access the employee accounts endpoint" do
      it "Then redirects to the login screen" do
        visit "/employee-accounts"
        expect(current_path).to eq("/log-in")
      end
    end

    context "When attempting to access the database status endpoint" do
      it "Then redirects to the login screen" do
        visit "/database-status"
        expect(current_path).to eq("/log-in")
      end
    end
  end

  context "Given a user authenticated as a barista" do
    before(:each) do
      log_in_as('testbarista@bbc.com', 'testbarista@bbc.com')
    end

    context "When attempting to access the manage accounts page" do
      it "Then redirects back onto the home root path" do
        visit "/manage-accounts"
        expect(current_path).to eq("/")
      end
    end

    context "When attempting to access the database status panel" do
      it "Then redirects back onto the home root path" do
        visit "/database-status"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as a standard customer" do
    before(:each) do
      log_in_as('testcust@bbc.com', 'testcust@bbc.com')
    end

    context "When attempting to access the manage accounts page" do
      it "Then redirects back onto the home root path" do
        visit "/manage-accounts"
        expect(current_path).to eq("/")
      end
    end

    context "When attempting to access the database status panel" do
      it "Then redirects back onto the home root path" do
        visit "/database-status"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as an administrator" do
    before(:each) do
      log_in_as('testadmin@bbc.com', 'testadmin@bbc.com')
    end

    context "When requesting administrative route domains" do
      it "Then allows navigation onto the manage accounts portal dashboard" do
        visit "/manage-accounts"
        expect(current_path).to eq("/manage-accounts")
      end

      it "Then allows navigation onto the flagged accounts registry tracking interface" do
        visit "/flagged-accounts"
        expect(current_path).to eq("/flagged-accounts")
      end

      it "Then allows navigation onto the specific administrator view order path" do
        visit "/order-management/administrator"
        expect(current_path).to eq("/order-management/administrator")
      end

      it "Then allows navigation onto the internal employee accounts profile registry" do
        visit "/employee-accounts"
        expect(current_path).to eq("/employee-accounts")
      end

      it "Then allows navigation onto the master database maintenance operations desk" do
        visit "/database-status"
        expect(current_path).to eq("/database-status")
      end
    end

    context "When monitoring empty storage within the system database panel" do
      it "Then renders the parent panel and outputs a safe fallback notice message" do
        visit "/database-status"
        expect(page).to have_selector("#db-status-dashboard-panel")
        expect(page).to have_content("No active save point archives found on disk.")
      end
    end

    context "When choosing to exit the running database interface dashboard" do
      it "Then routes back smoothly onto the primary master user registry grid" do
        visit "/database-status"
        click_link "Return to Admin Dashboard"
        expect(current_path).to eq("/manage-accounts")
      end
    end

    context "When viewing existing storage snapshots populated in the storage folder" do
      it "Then extracts details for file objects displaying correct size conversion units" do
        FileUtils.mkdir_p(backup_dir)
        test_file = File.join(backup_dir, "backup_20260514_120000.sqlite3")
        File.write(test_file, "mock data payload string structure footprint")

        visit "/database-status"
        expect(page).to have_content("backup_20260514_120000.sqlite3")
        expect(page).to have_content("0.04 KB")
      end
    end

    context "When viewing active registration metrics via the core dashboard grid" do
      it "Then lists primary database row entries together alongside identity values" do
        visit "/manage-accounts"
        expect(page).to have_content("1")
        expect(page).to have_content("Customer")
        expect(page).to have_content("Test")
      end

      it "Then provides an input field targeting specific client queries text search" do
        visit "/manage-accounts"
        expect(page).to have_field("accountSearch")
      end
    end

    context "When opting to isolate a particular row inside the account overview block" do
      it "Then safely transfers user focal point over to target edit entry pages" do
        visit "/manage-accounts"
        within(".acc-view__row", text: "testcust@bbc.com") do
          click_link "Edit Account"
        end
        expect(current_path).to eq("/edit-account/1")
      end
    end

    context "When executing review requests targeting editing windows for clients" do
      it "Then serves pre-populated inputs mirroring original model attribute state data" do
        visit "/edit-account/#{customer_id}"
        expect(find_field("first_name").value).to eq("Customer")
        expect(find_field("last_name").value).to  eq("Test")
        expect(find_field("email").value).to       eq("testcust@bbc.com")
      end
    end

    context "When updating profile records inside the account alteration suite" do
      it "Then writes basic metadata field properties and redirects back to grid view" do
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

      it "Then successfully alters target email string attributes in persistence" do
        visit "/edit-account/#{customer_id}"
        fill_in "email", with: "newemail@example.com"
        click_button "Save Changes"

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(account[:email]).to eq("newemail@example.com")
      end

      it "Then adjusts system tracking role levels mapping down directly to persistent layer" do
        visit "/edit-account/#{customer_id}"
        select "Barista", from: "account_type"
        click_button "Save Changes"

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(account[:account_type]).to eq("barista")
      end
    end

    context "When using the automated security configuration tools" do
      it "Then resets authentication hashes back to baseline value targets via confirmation" do
        visit "/edit-account/#{customer_id}"
        check "reset_password"
        click_button "Save Changes"

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(BCrypt::Password.new(account[:hashed_password])).to eq("password123")
      end

      it "Then guarantees persistence integrity stands fast when bypass flag left blank" do
        original_hash = DB[:Accounts].where(user_id: customer_id).get(:hashed_password)

        visit "/edit-account/#{customer_id}"
        uncheck "reset_password"
        click_button "Save Changes"

        account = DB[:Accounts].where(user_id: customer_id).first
        expect(account[:hashed_password]).to eq(original_hash)
      end
    end
    
    context "Given customer tracking references flag records as problematic" do
      before do
        DB[:Accounts].where(user_id: customer_id).update(flagged: true, flagged_at: Time.now)
      end

      context "When evaluating isolated monitoring dashboards within administrative modules" do
        it "Then displays profiles explicitly flagged inside observation arrays" do
          visit "/flagged-accounts"
          expect(page).to have_content("testcust@bbc.com")
        end

        it "Then masks records lacking security flags out of view parameters" do
          visit "/flagged-accounts"
          expect(page).not_to have_content("testadmin@bbc.com")
        end
      end

      context "When targeting an offending profile record with enforcement blocks" do
        it "Then safely invokes status bans and redirects administrators forward to list indexes" do
          visit "/suspend-account/#{customer_id}"
          expect(current_path).to eq("/flagged-accounts")

          account = DB[:Accounts].where(user_id: customer_id).first
          expect(account[:suspended]).to be_truthy
        end
      end

      context "When evaluating standard security checks across untainted core administrator roles" do
        it "Then maintains normal profile processing pathways clear of unexpected blocks" do
          DB[:Accounts].where(user_id: admin_id).update(suspended: false)
          visit "/flagged-accounts"
          account = DB[:Accounts].where(user_id: admin_id).first
          expect(account[:suspended]).to be_falsy
        end
      end
    end

    context "When managing the operational team profiles roster index" do
      it "Then groups staff items visibly based on corporate organization categories" do
        visit "/employee-accounts"
        expect(page).to have_content("testbarista@bbc.com")
        expect(page).to have_content("testmanager@bbc.com")
        expect(page).to have_content("testadmin@bbc.com")
      end

      it "Then executes permanent account deletion tasks and reverts layout cleanly" do
        visit "/employee-accounts"
        within(".acc-view__row", text: "testbarista@bbc.com") do
          click_button "Delete"
        end

        expect(current_path).to eq("/employee-accounts")
        expect(page).not_to have_content("testbarista@bbc.com")
        expect(DB[:Accounts].where(user_id: 2).first).to be_nil
      end
    end

    context "When accessing the core order fulfillment tracking pipeline" do
      it "Then outputs full monitoring structural frames tracking finalized order statuses" do
        visit "/order-management/administrator"
        expect(page).to have_content("Paid")
      end
    end
  end
end