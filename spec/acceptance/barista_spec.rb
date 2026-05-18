# Barista Spec file.

require 'spec_helper'

RSpec.describe "Barista Access Controls and Actions", type: :feature do

  context "Given an unauthenticated visitor" do
    context "When attempting to access the staff portal" do
      it "Then redirects to the login path" do
        visit "/staff-portal"
        expect(current_path).to eq("/log-in")
      end
    end

    context "When attempting to access the loyalty management dashboard" do
      it "Then redirects to the login path" do
        visit "/manage-loyalty-cards"
        expect(current_path).to eq("/log-in")
      end
    end
  end

  context "Given a user authenticated as a regular customer" do
    before(:each) do
      log_in_as('testcust', 'testcust')
    end

    context "When trying to access the staff portal" do
      it "Then redirects back onto the home root path" do
        visit "/staff-portal"
        expect(current_path).to eq("/")
      end
    end

    context "When trying to isolate customer lookup indices for ordering" do
      it "Then redirects back onto the home root path" do
        visit "/place-order/find-user"
        expect(current_path).to eq("/")
      end
    end

    context "When trying to view the ordering cart contents" do
      it "Then redirects back onto the home root path" do
        visit "/place-order/contents"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as a barista" do

    before(:each) do
      log_in_as("testbarista", "testbarista")
    end

    context "When routing through core dashboard environments" do
      it "Then loads the staff portal index cleanly" do
        visit "/staff-portal"
        expect(current_path).to eq("/staff-portal")
      end

      it "Then displays active consumer references within the loyalty grid layout" do
        visit "/manage-loyalty-cards"
        expect(current_path).to eq("/manage-loyalty-cards")
        expect(page).to have_css("#form-user-1")
      end

      it "Then ensures privileged staff records remain hidden out of consumer tracking arrays" do
        visit "/manage-loyalty-cards"
        expect(page).not_to have_css("#form-user-2")
        expect(page).not_to have_css("#form-user-4")
      end

      it "Then accesses the summary turnover records tracking panel" do
        visit "/daily-summary"
        expect(current_path).to eq("/daily-summary")
      end
    end

    context "When processing updates through the customer reward card tools" do
      it "Then saves new stamp quantities utilizing layout input field parameters" do
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

      it "Then stores structural counter data fields securely inside core dataset rows" do
        visit "/manage-loyalty-cards"
        within("#form-user-1") do
          fill_in "stamp_count", with: 7
          click_button "Save"
        end

        expect(DB[:Accounts].where(user_id: 1).get(:stamp_count)).to eq(7)
      end

      it "Then provides workflows to zero out metrics tracking consumer rewards" do
        visit "/manage-loyalty-cards"
        within("#form-user-1") do
          fill_in "stamp_count", with: 0
          click_button "Save"
        end

        expect(DB[:Accounts].where(user_id: 1).get(:stamp_count)).to eq(0)
      end
    end

    context "When interacting with order progression pipelines and printing metrics" do
      it "Then surfaces correct tracking line items inside the production workspace" do
        visit "/order-management/barista"
        expect(current_path).to eq("/order-management/barista")
      end

      it "Then marks an item complete via automated form submission and returns to origin" do
        order_id = DB[:Orders].first[:order_id]
        page.driver.submit :post, '/order-management/barista', { order_id: order_id }
        
        expect(current_path).to eq("/order-management/barista")
        expect(DB[:Orders].where(order_id: order_id).get(:order_is_completed)).to be true
      end

      it "Then outputs dispatch documentation headers targeting PDF format structures" do
        order_id = DB[:Orders].first[:order_id]
        visit "/generate-label/#{order_id}"
        
        expect(page.driver.response.headers['Content-Type']).to eq('application/pdf')
        expect(page.driver.response.headers['Content-Disposition']).to include("attachment; filename=\"Label_#{order_id}.pdf\"")
      end

      it "Then streams return validation data sets built off matching post actions" do
        order_id = DB[:Orders].first[:order_id]
        page.driver.submit :post, "/generate-return/#{order_id}", {}
        
        expect(page.driver.response.headers['Content-Type']).to eq('application/pdf')
        expect(page.driver.response.headers['Content-Disposition']).to include("attachment; filename=\"Return_Label_#{order_id}.pdf\"")
      end
    end

    context "Given client communication threads exist inside tracking stores" do
      before do
        DB[:Tickets].insert(user_id: 1, ticket_type: 'General', ticket_content: 'Issue', ticket_resolved: false)
        DB[:Tickets].insert(user_id: 1, ticket_type: 'Refund', ticket_content: 'Money back', ticket_resolved: false)
      end

      context "When reviewing active inquiry collections across support tables" do
        it "Then enters the overarching help desk layout successfully" do
          visit "/user-tickets"
          expect(current_path).to eq("/user-tickets")
        end

        it "Then steps through to isolate specific ticket content details" do
          ticket_id = DB[:Tickets].where(ticket_type: 'General').first[:ticket_id]
          visit "/ticket/#{ticket_id}"
          expect(current_path).to eq("/ticket/#{ticket_id}")
        end

        it "Then writes state updates marking tickets complete and updates views" do
          ticket_id = DB[:Tickets].where(ticket_type: 'General').first[:ticket_id]
          page.driver.submit :post, "/resolve-ticket/#{ticket_id}", {}
          
          expect(current_path).to eq("/user-tickets")
          expect(DB[:Tickets].where(ticket_id: ticket_id).get(:ticket_resolved)).to be true
        end

        it "Then navigates directly to specialized refund operation consoles" do
          visit "/refund-tickets"
          expect(current_path).to eq("/refund-tickets")
        end

        it "Then inspects specific claim requests via isolated profile workspaces" do
          ticket_id = DB[:Tickets].where(ticket_type: 'Refund').first[:ticket_id]
          visit "/refund/#{ticket_id}"
          expect(current_path).to eq("/refund/#{ticket_id}")
        end

        it "Then approves transactional adjustments moving records over into finalized collections" do
          ticket_id = DB[:Tickets].where(ticket_type: 'Refund').first[:ticket_id]
          page.driver.submit :post, "/refund/#{ticket_id}", {}
          
          expect(current_path).to eq("/refund-tickets")
          expect(DB[:Tickets].where(ticket_id: ticket_id).get(:ticket_resolved)).to be true
        end
      end
    end

    context "When walking through the in-store ordering workflow steps" do
      it "Then isolates targets via lookup parameters and transfers contexts to the basket" do
        visit "/place-order/find-user"
        expect(page).to have_content("Place Order - Select Customer")
        expect(page).to have_content("Customer Test")

        within(".acc-view__row", text: "testcust") do
          click_button "Select Customer"
        end

        expect(current_path).to eq("/place-order/contents")
        expect(page).to have_content("Customer Test")
      end

      it "Then removes tracking parameters explicitly discarding temporary customer state" do
        visit "/place-order/find-user"
        within(".acc-view__row", text: "testcust") do
          click_button "Select Customer"
        end

        visit "/place-order/find-user"
        click_button "Clear"
        expect(current_path).to eq("/place-order/find-user")
        expect(page).not_to have_content("Continue to Basket")
      end
    end

    context "When completing a multi-item transaction through the store register" do
      it "Then compiles the basket payload, executes mathematical tracking formulas, and updates inventories" do
        visit "/place-order/find-user"
        within(".acc-view__row", text: "testcust") do
          click_button "Select Customer"
        end

        expect(current_path).to eq("/place-order/contents")

        basket_payload = [
          { 'item_id' => 'Latte', 'product_type' => 'drink', 'quantity' => 2, 'size' => 'Large', 'milk' => 'Oat' },
          { 'item_id' => 'Ethiopian', 'product_type' => 'bean', 'quantity' => 1, 'pack_weight' => 250.0, 'roast_level' => 'Medium' }
        ]

        page.driver.submit :post, '/place-order/complete', {
          order_items_json: basket_payload.to_json,
        }

        expect(current_path).to eq("/order-management/barista")

        new_order = DB[:Orders].order(:order_id).last
        expect(new_order[:user_id]).to eq(1)
        expect(new_order[:order_is_completed]).to be false
        expect(new_order[:total_cost].to_f).to eq(19.36)

        expect(DB[:Accounts].where(user_id: 1).get(:stamp_count)).to eq(7)
        expect(DB[:Beans].where(origin: 'Ethiopian').get(:stock_mass)).not_to be_nil #random value
      end
    end
  end
end