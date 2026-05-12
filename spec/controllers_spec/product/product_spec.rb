RSpec.describe "User access product pages", type: :feature do
  before(:each) do
    spec_before
  end
  let(:user_id) { 10000001 }
  
  describe "Browsing Products" do
    it "displays the coffee beans page with seeded data" do
      visit '/coffee-beans'
      expect(page).to have_content('Ethiopian Yirgacheffe')
      expect(page).to have_content('£8.50')
    end

    it "displays the drinks page with seeded data" do
      visit '/drinks'
      expect(page).to have_content('Flat White')
      expect(page).to have_content('£3.50')
    end
  end

  describe "Basket Management" do
    it "allows a user to add a drink to the basket and view it" do
      visit '/drinks'
      # Assuming your HTML has a button 'Add to Basket' for DrinkID 1
      click_button 'Add to basket' 
      
      visit '/view-basket'
      expect(page).to have_content('Flat White')
      expect(page).to have_content('£3.50')
    end
  end

  context "when checking out" do
    before do
      # Log in John Doe
      log_in_as('john@example.com', '_p_')
      
      # Add an item to basket
      visit '/drinks'
      click_button 'Add to basket'
    end

    it "calculates the subtotal correctly on the checkout page" do
      visit '/checkout'
      # Price (3.50)
      expect(page).to have_content('3.5')
    end

    it "applies a loyalty discount when user has 9 stamps" do
      DB[:Accounts].where(UserID: user_id).update(StampCount: 9)
      
      visit '/checkout'
      # Price 3.50 - Discount 3.50 = 0.00
      expect(page).to have_content('0.0')
    end

    it "places an order using cash and updates stamp count" do
      visit '/checkout'
       'Pay on Delivery' # Assuming radio/label for cash
      click_button 'Place Order'

      expect(page).to have_current_path('/order-success')
      expect(page).to have_content('TXN-')
      
      # Verify stamp was added (1 for a drink)
      user = DB[:Accounts].where(UserID: user_id).first
      expect(user[:StampCount]).to eq(1)
    end
  end

  describe "Payment Gateway" do
    it "updates order status on successful payment callback" do
      # Log in

      log_in_as('john@example.com', '_p_')

      # Manually create a pending order to test the callback
      order_id = DB[:Orders].insert(
        UserID: user_id,
        OrderContents: '[{"id":"1","type":"drink"}]',
        payment_status: 'Pending',
        IsCompleted: false
      )

      # Simulate the callback from the "Gateway"
      visit "/payment-callback?order_id=#{order_id}&status=success"

      expect(page).to have_current_path('/order-success')
      
      order = DB[:Orders].where(OrderID: order_id).first
      expect(order[:payment_status]).to eq('Paid')
      expect(order[:IsCompleted]).to be true
    end
  end
end