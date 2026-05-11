RSpec.describe "Admin Management", type: :feature do
  let(:admin_id) { 99999999 }
  let(:customer_id) { 10000001 }

  describe "Access Control" do
    it "redirects unauthorized users to home" do
      visit "/staff-portal"
      expect(page.current_path).to eq("/")
    end
  end

  context "when logged in as administrator" do
    before do
      # Log in using seeded Admin
      visit '/login'
      fill_in 'email', with: 'admin@coffee.com'
      fill_in 'password', with: 'SecretPassword123'
      click_button 'Login'
    end

    describe "Account Management" do
      it "displays all accounts in the management view" do
        visit "/manage-accounts"
        expect(page).to have_content("John")
        expect(page).to have_content("admin@coffee.com")
      end

      it "updates a user's details and resets their password" do
        visit "/edit-account/#{customer_id}"
        fill_in "first_name", with: "Johnny"
        check "reset_password" # Matches params[:reset_password]
        click_button "Update Account"

        expect(page.current_path).to eq("/manage-accounts")
        
        user = DB[:Accounts].where(UserID: customer_id).first
        expect(user[:first_name]).to eq("Johnny")
        # Verify password was reset (BCrypt comparison)
        expect(BCrypt::Password.new(user[:hashedPassword])).to eq("password123")
      end
    end

    describe "Suspensions and Flagging" do
      it "suspends a flagged account" do
        # Manually flag the seeded user for the test
        DB[:Accounts].where(UserID: customer_id).update(Flagged: true)
        
        visit "/flagged-accounts"
        click_link "Suspend", href: "/suspend-account/#{customer_id}"

        expect(page.current_path).to eq("/flagged-accounts")
        expect(DB[:Accounts].where(UserID: customer_id).get(:Suspended)).to be true
      end
    end

    describe "Loyalty Management" do
      it "manually updates a user's stamp count" do
        visit "/manage-loyalty-cards"
        # Assuming your form has fields named user_id and stamp_count
        within("form#form-#{customer_id}") do
          fill_in "stamp_count", with: "8"
          click_button "Update"
        end

        expect(DB[:Accounts].where(UserID: customer_id).get(:StampCount)).to eq(8)
      end
    end

    describe "PDF Generation" do
      it "generates a shipping label PDF for an order" do
        # Seed an order to generate a label for
        order_id = DB[:Orders].insert(UserID: customer_id, totalCost: 10.0)
        
        visit "/generate-label/#{order_id}"
        
        # Verify PDF headers
        expect(page.response_headers['Content-Type']).to eq('application/pdf')
        expect(page.response_headers['Content-Disposition']).to include("Label_#{order_id}.pdf")
      end
    end
  end
end
