RSpec.describe "Account Management", type: :feature do
  let(:user_id) { 1 }

  describe "Unauthenticated access" do
    it "redirects to home when attempting to access account settings" do
      visit "/account-settings"
      expect(page.current_path).to eq("/")
    end
  end

  context "when logged in" do
    before (:each) do
      log_in_as('testcust@bbc.com', 'testpass')
    end

    describe "user visits accounts page" do
      it "shows the account settings page with user details" do
        visit "/account-settings"
        expected_name = DB[:Accounts].where(user_id: user_id)
        expect(page).to have_content("Hi, Customer")
        expect(page).to have_content("Personal Details")
      end
    end

    describe "user updates account details" do
      it "updates database and redirects to home" do
        visit "/account-settings"
        fill_in "first_name", with: "Jonathan"
        click_button "Submit"

        expect(page.current_path).to eq("/")
        

        user = DB[:Accounts].where(user_id: user_id).first
        expect(user[:first_name]).to eq("Jonathan")
      end
    end

    describe "user visits loyalty card page" do
      it "displays the QR code and correct stamp count" do
        # Update user stamps to verify display
        DB[:Accounts].where(user_id: user_id).update(stamp_count: 5)
        
        visit "/loyalty-card"
        expect(page).to have_selector('svg') # Check for the QR code SVG
        expect(page).to have_content("5")
      end
    end

    describe "user visits my orders page" do
      it "shows current and past orders correctly" do
        # Seed specific orders for this test context
        DB[:Orders].insert(user_id: user_id, is_completed: false, OrderContents: '{"item":"Latte"}', totalCost: 3.50)
        DB[:Orders].insert(user_id: user_id, is_completed: true, OrderContents: '{"item":"Cake"}', totalCost: 4.00)

        visit "/my-orders"
        expect(page).to have_content("Latte")
        expect(page).to have_content("Cake")
      end
    end
  end
end
