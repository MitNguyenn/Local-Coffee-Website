RSpec.describe "Account Management", type: :feature do
  let(:user_id) { 10000001 }

  describe "Unauthenticated access" do
    it "redirects to home when attempting to access account settings" do
      visit "/account-settings"
      expect(page.current_path).to eq("/")
    end
  end

  context "when logged in" do
    before (:each) do
      log_in_as('john@example.com', 'SecretPassword123')
    end
    
    # before do
    #   # Perform a standard login using your seeded John Doe
    #   visit '/log-in'
    #   fill_in 'email', with: 'john@example.com'
    #   fill_in 'password', with: 'SecretPassword123'
    #   click_button 'Log In'
    # end

    describe "user visits accounts page" do
      it "shows the account settings page with user details" do
        visit "/account-settings"
        expect(page).to have_content("John")
        expect(page).to have_content("Personal Details")
      end
    end

    describe "user updates account details" do
      it "updates database and redirects to home" do
        visit "/account-settings"
        fill_in "first_name", with: "Jonathan"
        click_button "Submit"

        expect(page.current_path).to eq("/")
        
        # Verify the DB change persisted through the redirect
        user = DB[:Accounts].where(UserID: user_id).first
        expect(user[:first_name]).to eq("Jonathan")
      end
    end

    describe "user visits loyalty card page" do
      it "displays the QR code and correct stamp count" do
        # Update user stamps to verify display
        DB[:Accounts].where(UserID: user_id).update(StampCount: 5)
        
        visit "/loyalty-card"
        expect(page).to have_selector('svg') # Check for the QR code SVG
        expect(page).to have_content("5")
      end
    end

    describe "user visits my orders page" do
      it "shows current and past orders correctly" do
        # Seed specific orders for this test context
        DB[:Orders].insert(UserID: user_id, IsCompleted: false, OrderContents: '{"item":"Latte"}', totalCost: 3.50)
        DB[:Orders].insert(UserID: user_id, IsCompleted: true, OrderContents: '{"item":"Cake"}', totalCost: 4.00)

        visit "/my-orders"
        expect(page).to have_content("Latte")
        expect(page).to have_content("Cake")
      end
    end
  end
end
