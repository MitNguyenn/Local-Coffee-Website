RSpec.describe "Admin Management", type: :feature do
  let(:admin_id)    { 4 }
  let(:customer_id) { 1 }

  before(:each) do
    log_in_as('testadmin@bbc.com', 'testpass')
  end

  describe "access control" do
    it "redirects an unauthenticated user away from manage-accounts" do
      Capybara.reset_sessions!
      visit "/manage-accounts"
      expect(current_path).to eq("/")
    end

    it "redirects an unauthenticated user away from flagged-accounts" do
      Capybara.reset_sessions!
      visit "/flagged-accounts"
      expect(current_path).to eq("/")
    end

    it "redirects a barista away from manage-accounts" do
      Capybara.reset_sessions!
      log_in_as('testbarista@bbc.com', 'testpass')
      visit "/manage-accounts"
      expect(current_path).to eq("/")
    end

    it "redirects a customer away from manage-accounts" do
      Capybara.reset_sessions!
      log_in_as('testcust@bbc.com', 'testpass')
      visit "/manage-accounts"
      expect(current_path).to eq("/")
    end
  end

  describe "Account Management Table" do
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

  describe "Edit Account" do
    it "renders the edit form pre-populated with the account's data" do
      visit "/edit-account/#{customer_id}"
      expect(find_field("first_name").value).to eq("Customer")
      expect(find_field("last_name").value).to  eq("Test")
      expect(find_field("email").value).to       eq("testcust@bbc.com")
    end

    it "updates first and last name and redirects to manage-accounts" do
      visit "/edit-account/#{customer_id}"
      fill_in "first_name", with: "Jane"
      fill_in "last_name",  with: "Smith"
      click_button "Save Changes"
      expect(current_path).to eq("/manage-accounts")

      account = DB[:Accounts].where(user_id: customer_id).first
      expect(account[:first_name]).to eq("Jane")
      expect(account[:last_name]).to  eq("Smith")
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
  
  describe "flagged Accounts" do
    before do
      DB[:Accounts].where(user_id: customer_id).update(flagged: true, flagged_at: Time.now)
    end

    it "renders the flagged accounts page" do
      visit "/flagged-accounts"
      expect(current_path).to eq("/flagged-accounts")
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

  describe "Order Management (administrator)" do
    it "renders the order management page" do
      visit "/order-management/administrator"
      expect(current_path).to eq("/order-management/administrator")
    end

    it "displays the seeded order" do
      visit "/order-management/administrator"
      expect(page).to have_content("#1")
    end

    it "displays the order's payment status" do
      visit "/order-management/administrator"
      expect(page).to have_content("Paid")
    end
  end

  describe "Metrics and Sales" do
    it "displays the metrics page with total sales" do
      visit "/metrics"
      expect(page).to have_content("Managerial Analytics")
    end
  end
end