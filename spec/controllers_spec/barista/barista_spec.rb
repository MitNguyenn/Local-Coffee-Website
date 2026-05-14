RSpec.describe "Barista access unique pages", type: :feature do

  context "Attempting to visit without valid creds" do
    describe "unauthorised access" do
      it "redirects an unlogged user to the home page" do
        visit "/staff-portal"
        expect(current_path).to eq("/")
      end

      it "redirects a plain customer to the home page" do
        log_in_as('testcust@bbc.com', 'testpass')
        visit "/staff-portal"
        expect(current_path).to eq("/")
      end

      it "redirects an unlogged user trying to access manage-loyalty-cards" do
        visit "/manage-loyalty-cards"
        expect(current_path).to eq("/")
      end
    end
  end

  context "as a logged-in barista" do
    before(:each) do
      log_in_as('testbarista@bbc.com', 'testpass')
    end

    it "can visit the staff portal and sees barista-specific links" do
      visit "/staff-portal"
      expect(current_path).to eq("/staff-portal")
      expect(page).to have_link("View Orders", href: "/order-management/barista")
      expect(page).to have_link("Manage Loyalty Cards", href: "/manage-loyalty-cards")
    end

    it "does not see manager or admin links on the staff portal" do
      visit "/staff-portal"
      expect(page).not_to have_link("View Metrics")
      expect(page).not_to have_link("Manage Accounts")
      expect(page).not_to have_link("Manage Stock")
    end

    it "can visit the manage loyalty cards page and sees customer accounts" do
      visit "/manage-loyalty-cards"
      expect(current_path).to eq("/manage-loyalty-cards")
      # John Doe is the seeded customer
      expect(page).to have_css("#form-user-1")
    end

    it "does not display staff accounts on the loyalty cards page" do
      visit "/manage-loyalty-cards"
      # Barista and admin accounts should not appear
      expect(page).not_to have_css("#form-user-2") # barista
      expect(page).not_to have_css("#form-user-4") # admin
    end

    it "updates a customer's stamps using their specific form" do
      visit "/manage-loyalty-cards"

      within("#form-user-1") do
        fill_in "stamp_count", with: 9
        click_button "Save"
      end

      expect(current_path).to eq("/manage-loyalty-cards")

      within("#form-user-1") do
        expect(find_field('stamp_count').value).to eq("9")
      end
    end

    it "persists the stamp update to the database" do
      visit "/manage-loyalty-cards"

      within("#form-user-1") do
        fill_in "stamp_count", with: 7
        click_button "Save"
      end

      expect(DB[:Accounts].where(user_id: 1).first[:stamp_count]).to eq(7)
    end

    it "can set stamps to zero" do
      DB[:Accounts].where(user_id: 1).update(stamp_count: 5)

      visit "/manage-loyalty-cards"

      within("#form-user-1") do
        fill_in "stamp_count", with: 0
        click_button "Save"
      end

      within("#form-user-1") do
        expect(find_field('stamp_count').value).to eq("0")
      end
    end
  end

  context "as a logged-in customer" do
    before(:each) do
      log_in_as('testcust@bbc.com', 'testpass')
    end

    it "cannot access manage-loyalty-cards" do
      visit "/manage-loyalty-cards"
      expect(current_path).to eq("/")
    end

    it "cannot post to update-stamps" do
      page.driver.submit :post, '/update-stamps', {
        user_id: 1,
        stamp_count: 10
      }
      expect(DB[:Accounts].where(user_id: 1).first[:stamp_count]).to eq(4)
    end
  end
  
  context "PDF management" do
    before(:each) do
      log_in_as('testbarista@bbc.com', 'testpass')
    end

    describe "Barista attempts to print shipping label" do
      it "orders table is viewable" do
        visit "/order-management/barista"  
        expect(current_path).to eq("/order-management/barista")
        expect(page).to have_content("Print Label")  
      end

      it "generates a PDF file successfully" do
        order_id = DB[:Orders].first[:order_id] 
        visit "/generate-label/#{order_id}"
        expect(page.driver.response.headers['Content-Type']).to eq('application/pdf')
        expect(page.driver.response.headers['Content-Disposition']).to include("attachment; filename=\"Label_#{order_id}.pdf\"")
      end
  end

  describe "Customer attempts to print shipping label" do
    it "redirects or denies access" do
      log_in_as('testcust@bbc.com', 'testpass')
      order_id = DB[:Orders].first[:order_id]
      visit "/generate-label/#{order_id}"
      expect(current_path).to eq("/")
    end
  end

  describe "Return Label Generation" do
    it "can view the create return page with the orders list" do
      visit "/generate-return"
      expect(current_path).to eq("/generate-return")
      expect(page).to have_content("Order #")
    end

    it "successfully generates a return PDF via POST" do
      order_id = DB[:Orders].where(is_completed: 1).first[:order_id]
      page.driver.submit :post, "/generate-return/#{order_id}", {
        external_tracking_id: 'EXT123456'
      }
      expect(page.driver.response.headers['Content-Type']).to eq('application/pdf')
      expect(page.driver.response.headers['Content-Disposition']).to include("attachment; filename=\"Return_Label_#{order_id}.pdf\"")
    end
  end
end
end