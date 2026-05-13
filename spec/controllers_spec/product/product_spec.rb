RSpec.describe "User access product pages", type: :feature do

  let(:user_id) { 10000001 }
  
  describe "Browsing Products" do
    it "displays the coffee beans page with seeded data" do
      visit '/coffee-beans'
      expect(page).to have_content('Ethiopian')
      expect(page).to have_content('£8.20')
      expect(page).to have_content('Brazillian')
      expect(page).to have_content('£6.35')
      expect(page).to have_content('Arabic')
      expect(page).to have_content('£4.75')
    end

    it "displays the drinks page with seeded data" do
      visit '/drinks'
      expect(page).to have_content('Latte')
      expect(page).to have_content('£4.40')
      expect(page).to have_content('Americano')
      expect(page).to have_content('£3.80')
      expect(page).to have_content('Cappuccino')
      expect(page).to have_content('£4.40')
      expect(page).to have_content('Flat White')
      expect(page).to have_content('£4.35')
      expect(page).to have_content('Cortado')
      expect(page).to have_content('£3.70')
    end
  end

  describe "Cart Management" do
    it "allows a user to add a drink to the cart and view it" do
      visit '/drinks'
      # Assuming your HTML has a button 'Add to Cart' for DrinkID 1
      click_button 'Add to cart' 
      
      visit '/view-cart'
      expect(page).to have_content('Flat White')
      expect(page).to have_content('£3.50')
    end
  end

  context "when checking out" do
    before do
      # Log in John Doe
      log_in_as('testcust@bbc.com', 'testpass')
      
      # Add an item to cart
      visit '/drinks'
      click_button 'Add to cart'
    end

    it "calculates the subtotal correctly on the checkout page" do
      visit '/checkout'
      # price (3.50)
      expect(page).to have_content('3.5')
    end

    it "applies a loyalty discount when user has 9 stamps" do
      DB[:Accounts].where(user_id: user_id).update(stamp_count: 9)
      
      visit '/checkout'
      # price 3.50 - Discount 3.50 = 0.00
      expect(page).to have_content('0.0')
    end

    it "places an order using cash and updates stamp count" do
      visit '/checkout'
       'Pay on Delivery' # Assuming radio/label for cash
      click_button 'Place Order'

      expect(page).to have_current_path('/order-success')
      expect(page).to have_content('TXN-')
      
      # Verify stamp was added (1 for a drink)
      user = DB[:Accounts].where(user_id: user_id).first
      expect(user[:stamp_count]).to eq(1)
    end
  end

  describe "Payment Gateway" do
    it "updates order status on successful payment callback" do
      # Log in

      log_in_as('testcust@bbc.com', 'testpass')

      # Manually create a pending order to test the callback
      order_id = DB[:Orders].insert(
        user_id: user_id,
        OrderContents: '[{"id":"1","type":"drink"}]',
        payment_status: 'Pending',
        is_completed: false
      )

      # Simulate the callback from the "Gateway"
      visit "/payment-callback?order_id=#{order_id}&status=success"

      expect(page).to have_current_path('/order-success')
      
      order = DB[:Orders].where(order_id: order_id).first
      expect(order[:payment_status]).to eq('Paid')
      expect(order[:is_completed]).to be true
    end
  end
end