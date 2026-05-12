RSpec.describe "Barista access unique pages", type: :feature do

  # 1. Test the Security Redirect
    describe "unauthorised access" do
    it "redirects an unlogged user to the home page" do
      visit "/staff-portal"
      expect(current_path).to eq("/")
    end

    it "redirects a plain customer to the home page" do
      log_in_as('john@example.com', '_p_')
      visit "/staff-portal"
      expect(current_path).to eq("/")
    end

    it "redirects an unlogged user trying to access manage-loyalty-cards" do
      visit "/manage-loyalty-cards"
      expect(current_path).to eq("/")
    end
  end

  # 2. Test Barista Actions
  context "as a logged-in barista" do
    before(:each) do
      log_in_as('barista@coffee.com', '_p_')
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
      expect(page).to have_css("#form-user-10000001")
    end

    it "does not display staff accounts on the loyalty cards page" do
      visit "/manage-loyalty-cards"
      # Barista and admin accounts should not appear
      expect(page).not_to have_css("#form-user-12345678") # barista
      expect(page).not_to have_css("#form-user-99999999") # admin
    end

    it "updates a customer's stamps using their specific form" do
      visit "/manage-loyalty-cards"

      within("#form-user-10000001") do
        fill_in "stamp_count", with: 9
        click_button "Save"
      end

      expect(current_path).to eq("/manage-loyalty-cards")

      within("#form-user-10000001") do
        expect(find_field('stamp_count').value).to eq("9")
      end
    end

    it "persists the stamp update to the database" do
      visit "/manage-loyalty-cards"

      within("#form-user-10000001") do
        fill_in "stamp_count", with: 7
        click_button "Save"
      end

      expect(DB[:Accounts].where(UserID: 10000001).first[:StampCount]).to eq(7)
    end

    it "can set stamps to zero" do
      DB[:Accounts].where(UserID: 10000001).update(StampCount: 5)

      visit "/manage-loyalty-cards"

      within("#form-user-10000001") do
        fill_in "stamp_count", with: 0
        click_button "Save"
      end

      within("#form-user-10000001") do
        expect(find_field('stamp_count').value).to eq("0")
      end
    end
  end

  # 3. Role boundary tests
  context "as a logged-in customer" do
    before(:each) do
      log_in_as('john@example.com', '_p_')
    end

    it "cannot access manage-loyalty-cards" do
      visit "/manage-loyalty-cards"
      expect(current_path).to eq("/")
    end

    it "cannot post to update-stamps" do
      page.driver.submit :post, '/update-stamps', {
        user_id: 10000001,
        stamp_count: 10
      }
      expect(DB[:Accounts].where(UserID: 10000001).first[:StampCount]).to eq(0)
    end
  end
end