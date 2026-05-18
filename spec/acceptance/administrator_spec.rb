# Administrator Spec file.

require 'spec_helper'
require 'fileutils'
require 'sqlite3'

RSpec.describe "Admin Management", type: :feature do
  let(:admin_id)    { 4 }
  let(:customer_id) { 1 }

  context "Given an unauthenticated visitor" do
    context "When attempting to access the manage accounts endpoint" do
      it "Then redirects to the login screen" do
        visit "/manage-accounts"
        expect(current_path).to eq("/")
      end
    end

    context "When attempting to access the flagged accounts endpoint" do
      it "Then redirects to the login screen" do
        visit "/flagged-accounts"
        expect(current_path).to eq("/")
      end
    end

    context "When attempting to access the employee accounts endpoint" do
      it "Then redirects to the login screen" do
        visit "/employee-accounts"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as a barista" do
    before(:each) do
      log_in_as('testbarista', 'testbarista')
    end

    context "When attempting to access the manage accounts page" do
      it "Then redirects back onto the home root path" do
        visit "/manage-accounts"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as a standard customer" do
    before(:each) do
      log_in_as('testcust', 'testcust')
    end

    context "When attempting to access the manage accounts page" do
      it "Then redirects back onto the home root path" do
        visit "/manage-accounts"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as an administrator" do
    before(:each) do
      log_in_as('testadmin', 'testadmin')
    end

    context "When requesting administrative route domains" do
      it "THhen allows them to visit the database management page" do
        visit'/database-status'

        expect(current_path).to eq("/database-status")
        expect(page).to have_content("Database Status Control Panel")
      end

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
        within(".acc-view__row", text: "testcust") do
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
        expect(find_field("email").value).to       eq("testcust")
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
        # Use user_id: 8 which is seeded specifically as flagged: true inside your seeder script
        DB[:Accounts].where(user_id: 8).update(flagged_at: Time.now)
      end

      context "When evaluating isolated monitoring dashboards within administrative modules" do
        it "Then displays profiles explicitly flagged inside observation arrays" do
          visit "/flagged-accounts"
          expect(page).to have_content("testflagged@bbc.com")
        end

        it "Then masks records lacking security flags out of view parameters" do
          visit "/flagged-accounts"
          expect(page).not_to have_content("testadmin")
        end
      end

      context "When targeting an offending profile record with enforcement blocks" do
        it "Then safely invokes status bans and redirects administrators forward to list indexes" do
          visit "/suspend-account/8"
          expect(current_path).to eq("/flagged-accounts")

          account = DB[:Accounts].where(user_id: 8).first
          expect(account[:suspended]).to be_truthy
        end
      end
    end

    context "Given corporate team members exist inside standard seeder entries" do
      context "When monitoring staff accounts index pages" do
        it "Then groups user cards based cleanly upon staff organizational classifications" do
          visit "/employee-accounts"
          expect(page).to have_content("testbarista")
          expect(page).to have_content("testmanager")
        end
      end

      context "When dropping internal profiles completely out of service registries" do
        it "Then submits deletion requests purging target lines and updates displays" do
          # User ID 11 is seeded by default as the 'testflag@bbc.com' customer account
          visit "/employee-accounts"
          page.driver.submit :post, "/delete-account/11", {}

          expect(current_path).to eq("/employee-accounts")
          expect(DB[:Accounts].where(user_id: 11).first).to be_nil
        end
      end
    end

    context "Given completed transactions exist with child relational tracking rows" do
      before do
        # Seed an explicit complete order transaction to safely isolate calculations from random generation noise
        @order_id = DB[:Orders].insert(
          user_id: customer_id, 
          total_cost: 11.16, 
          order_is_completed: true, 
          payment_is_completed: false, 
          created_at: Time.now
        )
        
        # Insert matching structural parameter elements matching your OrderItems rules
        DB[:OrderItems].insert(
          order_id: @order_id, 
          product_type: 'drink', 
          item_id: 'Latte',
          drink_size: 'Large', 
          milk_type: 'Oat', 
          quantity: 2
        )
      end

      context "When navigating into the administrative settlement logs" do
        it "Then evaluates relational loops mapping sub-item parameters into dynamic overview text lines" do
          visit "/order-management/administrator"
          expect(page).to have_content("2x drink [Large, w/ Oat]")
        end
      end

      context "When executing auditing price corrections with verification inputs" do
        it "Then accepts updates modifying transactional financial metrics and writes audit footprint summaries" do
          page.driver.submit :post, "/order-management/administrator", {
            order_id: @order_id.to_s,
            payment_status: "Paid",
            reason_note: "Customer settled balance at alternative terminal register counter"
          }

          expect(current_path).to eq("/order-management/administrator")
          expect(DB[:Orders].where(order_id: @order_id).get(:payment_is_completed)).to be_truthy

          audit_row = DB[:Audits].where(order_id: @order_id).first
          expect(audit_row).not_to be_nil
          expect(audit_row[:before_status]).to eq("Unpaid")
          expect(audit_row[:after_status]).to eq("Paid")
          expect(audit_row[:change_reason]).to include("alternative terminal register counter")
        end

        it "Then explicitly discards form post actions if verification rationale fields are missing" do
          page.driver.submit :post, "/order-management/administrator", {
            order_id: @order_id.to_s,
            payment_status: "Paid",
            reason_note: "Customer paid in cash - system failed to update accordingly"
          }

          expect(DB[:Orders].where(order_id: @order_id).get(:payment_is_completed)).to eq(true)
        end
      end
    end
  end
end