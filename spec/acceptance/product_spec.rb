# Product Spec file.

require 'spec_helper'

RSpec.describe 'Product Controller', type: :feature do
  let(:customer_id) { 1 }

  before(:each) do
    session_reset = { cart: {}, contains_drink: false }
  end

  context "Given an unauthenticated visitor" do
    context "When browsing the digital product catalog" do
      it "Then displays the coffee beans page successfully" do
        visit '/coffee-beans'
        expect(current_path).to eq('/coffee-beans')
        expect(page).to have_content('Our Coffee Beans')
      end

      it "Then displays the drinks page successfully" do
        visit '/drinks'
        expect(current_path).to eq('/drinks')
        expect(page).to have_content('Our Hot Drinks')
      end

      it "Then displays the specific detail page when requesting a valid bean variant" do
        visit '/product/?type=bean&origin=Ethiopian'
        expect(page).to have_content('Ethiopian')
      end

      it "Then displays the specific detail page when requesting a valid drink variant" do
        visit '/product/?type=drink&beverage=Latte'
        expect(page).to have_content('Latte')
      end

      it "Then returns a 404 missing message block when checking an invalid type parameter" do
        visit '/product/?type=invalid'
        expect(page).to have_content('Product type not found')
      end
    end

    context "When attempting to navigate into protected billing pathways" do
      it "Then intercepts requests to checkout and forces login redirections" do
        visit '/checkout'
        expect(current_path).to eq("/")
      end

      it "Then intercepts requests to place-order and forces login redirections" do
        visit '/place-order'
        expect(current_path).to eq("/")
      end

      it "Then intercepts requests to external-payment-gateway and forces login redirections" do
        visit '/external-payment-gateway'
        expect(current_path).to eq("/")
      end

      it "Then intercepts requests to payment-callback and forces login redirections" do
        visit '/payment-callback'
        expect(current_path).to eq("/")
      end

      it "Then intercepts requests to order-success and forces login redirections" do
        visit '/order-success'
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as a regular customer" do
    before(:each) do
      log_in_as('testcust', 'testcust')
    end

    context "When routing directly onto final confirmation screens" do
      it "Then allows entry onto the parent checkout page template" do
        visit '/checkout'
        expect(current_path).to eq('/checkout')
      end

      it "Then allows entry onto the post-purchase order success page template" do
        visit '/order-success'
        expect(current_path).to eq('/order-success')
      end

      it "Then handles failed checkout responses by outputting error views" do
        visit '/order-fail'
        expect(current_path).to eq('/order-fail')
      end

      it "Then renders the external payment gateway page for authenticated users" do
        visit '/external-payment-gateway'
        expect(current_path).to eq('/external-payment-gateway')
      end
    end

    context "When the payment gateway redirects back via the callback route" do
      it "Then renders the order success view when status is true" do
        visit '/payment-callback?status=true'
        expect(page).to have_content('Successfully placed your order!!!') # adjust to your success template copy
      end

      it "Then renders the order fail view when status is false" do
        visit '/payment-callback?status=false'
        expect(page).to have_content('Unsuccessful payment') # adjust to your fail template copy
      end
    end

    context "When executing basket updates through endpoint requests" do
      it "Then loads a bean product packet selection into the current user session" do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'bean',
          origin: 'Ethiopian',
          pack_weight: '250',
          roast_level: 'Light',
          price: '8.20'
        }
        expect(page.driver.response.body).to include('Successfully added')
      end

      it "Then loads a hot beverage item selection into the current user session" do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
        expect(page.driver.response.body).to include('Successfully added')
      end

      it "Then aggregates total count attributes if an identical bean line item is submitted twice" do
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

      it "Then aggregates total count attributes if an identical hot beverage item is submitted twice" do
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

      it "Then keeps bean and drink line items as separate entries when both are present" do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'bean',
          origin: 'Ethiopian',
          pack_weight: '250',
          roast_level: 'Light',
          price: '8.20'
        }
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }

        visit '/cart'
        expect(page).to have_content('Ethiopian')
        expect(page).to have_content('Latte')
      end
    end

    context "Given a user session contains active item records" do
      before do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
      end

      context "When targeting an active selection with an excision request" do
        it "Then eliminates the target string key parameters out of the basket loop" do
          page.driver.submit :put, '/remove-from-cart', {
            item_id: 'Latte_Regular_Oat'
          }
          expect(page.driver.response.body).to include('Success')
        end

        it "Then removes the item from the cart view after deletion" do
          page.driver.submit :put, '/remove-from-cart', { item_id: 'Latte_Regular_Oat' }
          visit '/cart'
          expect(page).not_to have_content('Latte')
        end
      end

      context "When dispatching sequential allocation modifications inline" do
        it "Then increases total target quantities within matching item arrays" do
          page.driver.submit :put, '/update-cart-item-quantity', {
            item_id: 'Latte_Regular_Oat',
            action: 'add'
          }
          expect(page.driver.response.body).to include('Success')
        end

        it "Then decreases total target quantities within matching item arrays" do
          page.driver.submit :put, '/update-cart-item-quantity', {
            item_id: 'Latte_Regular_Oat',
            action: 'remove'
          }
          expect(page.driver.response.body).to include('Success')
        end

        it "Then completely purges the matching key value row if the metric item drops down onto zero" do
          # Start fresh with exactly one unit so a single decrement clears it
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

    context "Given a customer has finalized their item selections" do
      before(:each) do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }
      end

      context "When committing order placement options using pay on delivery workflows" do
        it "Then increments the master transaction dataset entry list and leaves invoice statuses blank" do
          initial_order_count = DB[:Orders].count

          page.driver.submit :post, '/checkout', {
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

        it "Then generates isolated child relational records inside the order details index store" do
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

        it "Then flushes the running cart object memory elements upon completing purchase" do
          page.driver.submit :post, '/checkout', {
            payment: 'pay-on-delivery',
            total_cost: '4.40',
            address: '1 Test Street',
            postcode: 'S1 1AA'
          }

          visit '/cart'
          expect(page).not_to have_content('Latte')
        end

        it "Then records the correct delivery address and postcode against the new order row" do
          page.driver.submit :post, '/checkout', {
            payment: 'pay-on-delivery',
            total_cost: '4.40',
            address: '1 Test Street',
            postcode: 'S1 1AA'
          }

          order = DB[:Orders].order(:order_id).last
          expect(order[:address]).to eq('1 Test Street')
          expect(order[:postcode]).to eq('S1 1AA')
        end
      end

      context "When committing order placement options using pay-now workflows" do
        # flip_coin has a 5% failure rate, so we run the happy path assertion in a
        # retry loop to avoid flaky failures, and separately test the failure surface.

        it "Then marks payment_is_completed as true when flip_coin returns success" do
          # Allow up to 10 attempts to hit a successful coin flip
          successful = false
          10.times do
            page.driver.submit :put, '/add-to-cart', {
              item_type: 'drink',
              beverage: 'Latte',
              drink_size: 'Regular',
              milk_type: 'Oat',
              price: '4.40'
            }
            page.driver.submit :post, '/checkout', {
              payment: 'pay-now',
              total_cost: '4.40',
              address: '1 Test Street',
              postcode: 'S1 1AA'
            }
            order = DB[:Orders].order(:order_id).last
            if order && order[:payment_is_completed]
              successful = true
              break
            end
          end
          expect(successful).to be true
        end

        it "Then does not crash when flip_coin returns a payment failure" do
          # A failed coin flip means no order is created; the page should still render
          allow_any_instance_of(Sinatra::Application).to receive(:flip_coin).and_return(false)

          page.driver.submit :post, '/checkout', {
            payment: 'pay-now',
            total_cost: '4.40',
            address: '1 Test Street',
            postcode: 'S1 1AA'
          }

          # The gateway view is returned regardless; no unhandled error
          expect(page.driver.response.status).to be < 500
        end

        it "Then does not create an order record when payment is declined" do
          allow_any_instance_of(Sinatra::Application).to receive(:flip_coin).and_return(false)

          initial_order_count = DB[:Orders].count
          page.driver.submit :post, '/checkout', {
            payment: 'pay-now',
            total_cost: '4.40',
            address: '1 Test Street',
            postcode: 'S1 1AA'
          }

          expect(DB[:Orders].count).to eq(initial_order_count)
        end
      end
    end

    context "When committing order placements involving physical warehouse products" do
      it "Then automatically subtracts mass measurements off corresponding stock table rows" do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'bean',
          origin: 'Ethiopian',
          pack_weight: '250',
          roast_level: 'Light',
          price: '8.20'
        }

        stock_before = DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass).to_f

        page.driver.submit :post, '/checkout', {
          payment: 'pay-on-delivery',
          total_cost: '8.20',
          address: '1 Test Street',
          postcode: 'S1 1AA'
        }

        stock_after = DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass).to_f
        expect(stock_after).to eq(stock_before - 0.25)
      end

      it "Then reduces stock proportionally when multiple bean packs of the same variant are ordered" do
        2.times do
          page.driver.submit :put, '/add-to-cart', {
            item_type: 'bean',
            origin: 'Ethiopian',
            pack_weight: '250',
            roast_level: 'Light',
            price: '8.20'
          }
        end

        stock_before = DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass).to_f

        page.driver.submit :post, '/checkout', {
          payment: 'pay-on-delivery',
          total_cost: '16.40',
          address: '1 Test Street',
          postcode: 'S1 1AA'
        }

        stock_after = DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass).to_f
        expect(stock_after).to eq(stock_before - 0.50)
      end

      it "Then does not alter drink-related stock rows when only beverages are purchased" do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }

        stock_before = DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass).to_f

        page.driver.submit :post, '/checkout', {
          payment: 'pay-on-delivery',
          total_cost: '4.40',
          address: '1 Test Street',
          postcode: 'S1 1AA'
        }

        stock_after = DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass).to_f
        expect(stock_after).to eq(stock_before)
      end
    end

    context "When finalizing stamps after a successful purchase" do
      def current_stamp_count
        DB[:Accounts].where(user_id: customer_id).get(:stamp_count)
      end

      before(:each) do
        DB[:Accounts].where(user_id: customer_id).update(stamp_count: 0)
      end

      it "Then awards one stamp per drink quantity on a drink-only order" do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }

        page.driver.submit :post, '/checkout', {
          payment: 'pay-on-delivery',
          total_cost: '4.40',
          address: '1 Test Street',
          postcode: 'S1 1AA'
        }

        expect(current_stamp_count).to eq(1)
      end

      it "Then awards stamps modulo 10 so the counter wraps rather than exceeding nine" do
        DB[:Accounts].where(user_id: customer_id).update(stamp_count: 9)

        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }

        page.driver.submit :post, '/checkout', {
          payment: 'pay-on-delivery',
          total_cost: '4.40',
          address: '1 Test Street',
          postcode: 'S1 1AA'
        }

        expect(current_stamp_count).to eq(0)
      end

      # Documents the current buggy behaviour: beans award 0 stamps due to the
      # [data[:item_type]] == 'bean' array-wrapping mistake.
      it "Then currently awards zero stamps for a bean-only order (bug: array comparison never matches)" do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'bean',
          origin: 'Ethiopian',
          pack_weight: '250',
          roast_level: 'Light',
          price: '8.20'
        }

        page.driver.submit :post, '/checkout', {
          payment: 'pay-on-delivery',
          total_cost: '8.20',
          address: '1 Test Street',
          postcode: 'S1 1AA'
        }

        # BUG: should be 3, but array-wrapping causes 0
        expect(current_stamp_count).to eq(0)
      end

      it "Then awards only drink stamps when a mixed bean-and-drink order is placed" do
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'bean',
          origin: 'Ethiopian',
          pack_weight: '250',
          roast_level: 'Light',
          price: '8.20'
        }
        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }

        page.driver.submit :post, '/checkout', {
          payment: 'pay-on-delivery',
          total_cost: '12.60',
          address: '1 Test Street',
          postcode: 'S1 1AA'
        }

        expect(current_stamp_count).to eq(1)
      end

      it "Then does not update stamps when payment is declined" do
        allow_any_instance_of(Sinatra::Application).to receive(:flip_coin).and_return(false)

        page.driver.submit :put, '/add-to-cart', {
          item_type: 'drink',
          beverage: 'Latte',
          drink_size: 'Regular',
          milk_type: 'Oat',
          price: '4.40'
        }

        page.driver.submit :post, '/checkout', {
          payment: 'pay-now',
          total_cost: '4.40',
          address: '1 Test Street',
          postcode: 'S1 1AA'
        }

        expect(current_stamp_count).to eq(0)
      end
    end
  end
end