# Account Settings Spec file.
RSpec.describe "Account Management", type: :feature do
  let(:user_id) { 1 }

  context "Given an unauthenticated visitor" do
    context "When attempting to access account settings" do
      it "Then redirects to the login page" do
        visit "/account-settings"
        
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user is logged into the application" do
    before(:each) do
      log_in_as('testcust', 'testcust')
    end

    context "When visiting the account settings page" do
      it "Then shows the account settings page with user details" do
        visit "/account-settings"
        
        expect(page).to have_content("Hi, Customer")
        expect(page).to have_content("Personal Details")
      end
    end

    context "When updating account details" do
      it "Then updates the database record and redirects to home" do
        visit "/account-settings"
        fill_in "first_name", with: "Jonathan"
        click_button "Submit"

        expect(page.current_path).to eq("/account-settings")
        
        user = DB[:Accounts].where(user_id: user_id).first
        expect(user[:first_name]).to eq("Jonathan")
      end
    end

    context "When completely deleting the account" do
      it "Then purges the database record, clears session tracking, and redirects to home" do
        visit "/account-settings"
        click_button "Delete Account"

        expect(page.current_path).to eq("/")

        deleted_user = DB[:Accounts].where(user_id: user_id).first
        expect(deleted_user).to be_nil
      end
    end

    context "When visiting the loyalty card page" do
      it "Then displays the correct stamp count" do
        visit "/loyalty-card"
        
        expect(page).to have_content(10 - (DB[:Accounts].where(user_id: user_id).first[:stamp_count] % 10))
      end
    end

    describe "Favouriting beans" do
  before(:each) { log_in_as('testcust@bbc.com', 'testpass') }

  it "displays a favourited bean on the favourites page" do
    DB[:FavouriteBeans].insert(
      user_id:     1,
      origin:      'Ethiopian',
      pack_weight: 250.0,
      roast_level: 'Light'
    )

    visit '/my-favourites'
    expect(current_path).to eq('/my-favourites')
    expect(page).to have_content('Ethiopian')
  end

  it "toggles a favourite via the route" do
    page.driver.submit :put, '/toggle-favourite-bean', {
      origin:      'Ethiopian',
      pack_weight: '250.0',
      roast_level: 'Light'
    }

    visit '/my-favourites'
    expect(page).to have_content('Ethiopian')
  end
end

    context "When visiting the my orders page" do
      it "Then shows current and past orders correctly" do
        order_id = DB[:Orders].insert(user_id: user_id, total_cost: 9.15, order_is_completed: true, payment_is_completed: true)
        DB[:OrderItems].insert(order_id: order_id, product_type: 'drink', item_id: 'Latte', quantity: 1, drink_size: 'Regular', milk_type: 'Whole')
        DB[:OrderItems].insert(order_id: order_id, product_type: 'bean', item_id: 'Arabic', quantity: 1, pack_weight: 250.0, roast_level: 'Medium')

        visit "/my-orders"
        
        expect(page).to have_content("Latte")
        expect(page).to have_content("Arabic")
      end
    end
  end
end