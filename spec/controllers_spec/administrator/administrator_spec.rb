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
      visit '/login'
      fill_in 'email', with: 'admin@coffee.com'
      fill_in 'password', with: 'SecretPassword123'
      click_button 'Login'
    end

    describe "Account Management" do
      it "displays all tiered accounts in the management view" do
        visit "/manage-accounts"
        expect(page).to have_content("John")    # Customer
        expect(page).to have_content("Manager") # Manager
        expect(page).to have_content("Barista") # Barista
      end

      it "updates a user's details and resets their password" do
        visit "/edit-account/#{customer_id}"
        fill_in "first_name", with: "Johnny"
        check "reset_password" 
        click_button "Update Account"

        expect(page.current_path).to eq("/manage-accounts")
        
        user = DB[:Accounts].where(UserID: customer_id).first
        expect(user[:first_name]).to eq("Johnny")
        # Matches the 'hashed_password' column name in your spec_functions.rb
        expect(BCrypt::Password.new(user[:hashed_password])).to eq("password123")
      end
    end

    describe "Suspensions and Flagging" do
      it "suspends a flagged account" do
        DB[:Accounts].where(UserID: barista_id).update(Flagged: true)
        
        visit "/flagged-accounts"
        # Using a precise selector for the specific user's suspend link
        find("a[href='/suspend-account/#{barista_id}']").click

        expect(page.current_path).to eq("/flagged-accounts")
        expect(DB[:Accounts].where(UserID: barista_id).get(:Suspended)).to be true
      end
    end

    describe "Loyalty Management" do
      it "manually updates a customer's stamp count" do
        visit "/manage-loyalty-cards"
        # Target the specific form for the customer
        within("form#form-#{customer_id}") do
          fill_in "stamp_count", with: "8"
          click_button "Update"
        end

        expect(DB[:Accounts].where(UserID: customer_id).get(:StampCount)).to eq(8)
      end
    end

    describe "PDF Generation" do
      it "generates a shipping label PDF for an order" do
        # Use existing seeded order or create one for the test
        order_id = DB[:Orders].where(UserID: customer_id).get(:OrderID)
        
        visit "/generate-label/#{order_id}"
        
        expect(page.response_headers['Content-Type']).to eq('application/pdf')
        expect(page.response_headers['Content-Disposition']).to include("Label_#{order_id}.pdf")
      end
    end
  end
end
