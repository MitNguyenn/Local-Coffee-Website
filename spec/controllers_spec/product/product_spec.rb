RSpec.describe 'Product Controller', type: :feature do
  let(:customer_id) { 1 }

  before(:each) do
    session_reset = { cart: {}, contains_drink: false }
  end

  describe 'Product browsing' do
    it 'displays the coffee beans page' do
      visit '/coffee-beans'
      expect(current_path).to eq('/coffee-beans')
      expect(page).to have_content('Our Coffee Beans')
    end

    it 'displays the drinks page' do
      visit '/drinks'
      expect(current_path).to eq('/drinks')
      expect(page).to have_content('Our Hot Drinks')
    end

    it 'displays bean detail page for a valid bean' do
      visit '/product/?type=bean&origin=Ethiopian'
      expect(page).to have_content('Ethiopian')
    end

    it 'displays drink detail page for a valid drink' do
      visit '/product/?type=drink&beverage=Latte'
      expect(page).to have_content('Latte')
    end

    it 'returns 404 for an invalid product type' do
      visit '/product/?type=invalid'
      expect(page).to have_content('Product type not found')
    end
  end


  describe 'Checkout access control' do
    it 'redirects unauthenticated users from /checkout to log-in' do
      visit '/checkout'
      expect(current_path).to eq('/log-in')
    end

    it 'redirects unauthenticated users from /order-success to log-in' do
      visit '/order-success'
      expect(current_path).to eq('/log-in')
    end

    it 'redirects unauthenticated users from /payment-callback to log-in' do
      visit '/payment-callback'
      expect(current_path).to eq('/log-in')
    end

    context 'when logged in as a customer' do
      before(:each) { log_in_as('testcust@bbc.com', 'testpass') }

      it 'allows access to checkout page' do
        visit '/checkout'
        expect(current_path).to eq('/checkout')
      end

      it 'allows access to order-success page' do
        visit '/order-success'
        expect(current_path).to eq('/order-success')
      end
    end
  end


  describe 'Cart management' do
    before(:each) { log_in_as('testcust@bbc.com', 'testpass') }

    describe 'Adding items' do
      it 'adds a bean to the cart' do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'bean',
          origin: 'Ethiopian',
          pack_weight: '250',
          roast_level: 'Light',
          price: '8.20'
        }
        expect(page.driver.response.body).to include('Successfully added')
      end

      it 'adds a drink to the cart' do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
        expect(page.driver.response.body).to include('Successfully added')
      end

      it 'increments quantity when the same bean is added twice' do
        params = {
          item_type: 'bean',
          origin: 'Ethiopian',
          pack_weight: '250',
          roast_level: 'Light',
          price: '8.20'
        }
        page.driver.submit :put, '/add-to-cart', params
        page.driver.submit :put, '/add-to-cart', params

        visit '/cart'
        expect(page).to have_content('2')
      end

      it 'increments quantity when the same drink is added twice' do
        params = {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
        page.driver.submit :put, '/add-to-cart', params
        page.driver.submit :put, '/add-to-cart', params

        visit '/cart'
        expect(page).to have_content('2')
      end
    end

    describe 'Removing items' do
      before do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
      end

      it 'removes an item from the cart' do
        page.driver.submit :put, '/remove-from-cart', {
          item_id: 'Latte_Regular_Oat'
        }
        expect(page.driver.response.body).to include('Success')
      end
    end

    describe 'Updating quantity' do
      before do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
      end

      it 'increases item quantity' do
        page.driver.submit :put, '/update-cart-item-quantity', {
          item_id: 'Latte_Regular_Oat',
          action: 'add'
        }
        expect(page.driver.response.body).to include('Success')
      end

      it 'decreases item quantity' do
        page.driver.submit :put, '/update-cart-item-quantity', {
          item_id: 'Latte_Regular_Oat',
          action: 'remove'
        }
        expect(page.driver.response.body).to include('Success')
      end

      it 'removes item when quantity is decremented to zero' do
        # Start with quantity 1
        page.driver.submit :put, '/remove-from-cart', { item_id: 'Latte_Regular_Oat' }
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
        page.driver.submit :put, '/update-cart-item-quantity', {
          item_id: 'Latte_Regular_Oat',
          action: 'remove'
        }
        visit '/cart'
        expect(page).not_to have_content('Latte')
      end
    end
  end


  describe 'Checkout and order placement' do
    before(:each) do
      log_in_as('testcust@bbc.com', 'testpass')
      # Add a drink to cart
      page.driver.submit :put, '/add-to-cart', {
        item_type: 'drink',
        beverage: 'Latte',
        drink_size: 'Regular',
        milk_type: 'Oat',
        price: '4.40'
      }
    end

    it 'places an order with pay on delivery and creates DB records' do
      initial_order_count = DB[:Orders].count

      page.driver.submit :post, '/place-order', {
        payment: 'pay-on-delivery',
        total_cost: '4.40',
        address: '1 Test Street',
        postcode: 'S1 1AA'
      }

      expect(DB[:Orders].count).to eq(initial_order_count + 1)

      order = DB[:Orders].order(:order_id).last
      expect(order[:user_id]).to eq(customer_id)
      expect(order[:total_cost]).to eq(4.40)
      expect(order[:payment_is_completed]).to be_falsy
    end

    it 'creates OrderItems records when placing an order' do
      page.driver.submit :post, '/checkout', {
        payment: 'pay-on-delivery',
        total_cost: '4.40',
        address: '1 Test Street',
        postcode: 'S1 1AA'
      }

      order = DB[:Orders].order(:order_id).last
      items = DB[:OrderItems].where(order_id: order[:order_id]).all
      expect(items).not_to be_empty
      expect(items.any? { |item| item[:item_id] == 'Latte' })
    end

    it 'clears the cart after a successful order' do
      page.driver.submit :post, '/place-order', {
        payment: 'pay-on-delivery',
        total_cost: '4.40',
        address: '1 Test Street',
        postcode: 'S1 1AA'
      }

      visit '/cart'
      expect(page).not_to have_content('Latte')
    end

    it 'deducts bean stock when beans are ordered' do

      page.driver.submit :put, '/add-to-cart', {
        item_type: 'bean',
        origin: 'Ethiopian',
        pack_weight: '250',
        roast_level: 'Light',
        price: '8.20'
      }

      stock_before = DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass).to_f

      page.driver.submit :post, '/place-order', {
        payment: 'pay-later',
        total_cost: '12.60',
        address: '1 Test Street',
        postcode: 'S1 1AA'
      }

      stock_after = DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass).to_f
      expect(stock_after).to eq(stock_before - 0.25)
    end
  end


  describe 'Order fail page' do
    before(:each) { log_in_as('testcust@bbc.com', 'testpass') }

    it 'displays the order fail page' do
      visit '/order-fail'
      expect(current_path).to eq('/order-fail')
    end
  end
end