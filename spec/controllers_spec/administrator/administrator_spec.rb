RSpec.describe "Admin Management", type: :feature do
  let(:admin_id)    { 99999999 }
  let(:customer_id) { 10000001 }

  before(:each) do
    log_in_as('admin@coffee.com', '_p_')
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
      log_in_as('barista@coffee.com', '_p_')
      visit "/manage-accounts"
      expect(current_path).to eq("/")
    end

    it "redirects a customer away from manage-accounts" do
      Capybara.reset_sessions!
      log_in_as('john@example.com', '_p_')
      visit "/manage-accounts"
      expect(current_path).to eq("/")
    end
  end

  describe "Account Management Table" do
    it "displays all seeded accounts with correct IDs" do
      visit "/manage-accounts"
      expect(page).to have_content("10000001")
      expect(page).to have_content("John Doe")
      expect(page).to have_content("customer")
    end

    it "has a functional search input field" do
      visit "/manage-accounts"
      expect(page).to have_field("accountSearch")
    end

    it "navigates to the edit page via the table button" do
      visit "/manage-accounts"
      within(".acc-view__row", text: "john@example.com") do
        click_link "Edit Account"
      end
      expect(current_path).to eq("/edit-account/10000001")
    end
  end

  describe "Edit Account" do
    it "renders the edit form pre-populated with the account's data" do
      visit "/edit-account/#{customer_id}"
      expect(find_field("first_name").value).to eq("John")
      expect(find_field("last_name").value).to  eq("Doe")
      expect(find_field("email").value).to       eq("john@example.com")
    end

    it "updates first and last name and redirects to manage-accounts" do
      visit "/edit-account/#{customer_id}"
      fill_in "first_name", with: "Jane"
      fill_in "last_name",  with: "Smith"
      click_button "Save Changes"
      expect(current_path).to eq("/manage-accounts")

      account = DB[:Accounts].where(UserID: customer_id).first
      expect(account[:first_name]).to eq("Jane")
      expect(account[:last_name]).to  eq("Smith")
    end

    it "updates the email address" do
      visit "/edit-account/#{customer_id}"
      fill_in "email", with: "newemail@example.com"
      click_button "Save Changes"

      account = DB[:Accounts].where(UserID: customer_id).first
      expect(account[:email]).to eq("newemail@example.com")
    end

    it "updates the account type" do
      visit "/edit-account/#{customer_id}"
      select "Barista", from: "AccountType"
      click_button "Save Changes"

      account = DB[:Accounts].where(UserID: customer_id).first
      expect(account[:AccountType]).to eq("barista")
    end

    it "resets the password to 'password123' when the reset checkbox is ticked" do
      visit "/edit-account/#{customer_id}"
      check "reset_password"
      click_button "Save Changes"

      account = DB[:Accounts].where(UserID: customer_id).first
      expect(BCrypt::Password.new(account[:hashed_password])).to eq("password123")
    end

    it "does not change the password when reset checkbox is not ticked" do
      original_hash = DB[:Accounts].where(UserID: customer_id).get(:hashed_password)

      visit "/edit-account/#{customer_id}"
      uncheck "reset_password"
      click_button "Save Changes"

      account = DB[:Accounts].where(UserID: customer_id).first
      expect(account[:hashed_password]).to eq(original_hash)
    end
  end
  
  describe "Flagged Accounts" do
    before do
      DB[:Accounts].where(UserID: customer_id).update(Flagged: true, Flagged_At: Time.now)
    end

    it "renders the flagged accounts page" do
      visit "/flagged-accounts"
      expect(current_path).to eq("/flagged-accounts")
    end

    it "displays accounts that are flagged" do
      visit "/flagged-accounts"
      expect(page).to have_content("john@example.com")
    end

    it "does not display unflagged accounts" do
      visit "/flagged-accounts"
      expect(page).not_to have_content("admin@coffee.com")
    end

    it "suspends an account and redirects to flagged-accounts" do
      visit "/suspend-account/#{customer_id}"
      expect(current_path).to eq("/flagged-accounts")

      account = DB[:Accounts].where(UserID: customer_id).first
      expect(account[:Suspended]).to be_truthy
    end

    it "does not suspend an already-clean account unintentionally" do
      DB[:Accounts].where(UserID: admin_id).update(Suspended: false)
      visit "/flagged-accounts"
      account = DB[:Accounts].where(UserID: admin_id).first
      expect(account[:Suspended]).to be_falsy
    end
  end

  describe "Order Management (administrator)" do
    it "renders the order management page" do
      visit "/order-management/administrator"
      expect(current_path).to eq("/order-management/administrator")
    end

    it "displays the seeded order" do
      visit "/order-management/administrator"
      # Seeded order total is 7.00
      expect(page).to have_content("7")
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