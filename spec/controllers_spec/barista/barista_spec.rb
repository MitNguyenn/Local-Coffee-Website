RSpec.describe "Barista Access Controls and Actions", type: :feature do

  describe "Attempts to visit pages without valid credentials" do
    it "redirects an unauthenticated user to the login path" do
      visit "/staff-portal"
      expect(current_path).to eq("/")
    end

    it "redirects a regular customer to the home page" do
      log_in_as('testcust@bbc.com', 'testpass')
      visit "/staff-portal"
      expect(current_path).to eq("/")
    end

    it "redirects an unauthenticated user trying to access loyalty dashboards" do
      visit "/manage-loyalty-cards"
      expect(current_path).to eq("/")
    end
  end

  context "As a logged-in barista" do
    before(:each) do
      log_in_as('testbarista@bbc.com', 'testpass')
    end

    describe "Portal Navigation Boundaries" do
      it "can visit the staff portal cleanly" do
        visit "/staff-portal"
        expect(current_path).to eq("/staff-portal")
      end

      it "can view live customer records inside the loyalty management dashboard" do
        visit "/manage-loyalty-cards"
        expect(current_path).to eq("/manage-loyalty-cards")
        expect(page).to have_css("#form-user-1")
      end

      it "hides administrative or staff profile structures from loyalty lists" do
        visit "/manage-loyalty-cards"
        expect(page).not_to have_css("#form-user-2")
        expect(page).not_to have_css("#form-user-4")
      end
    end

    describe "Loyalty Stamp Operations" do
      it "updates a customer's total stamp balance using the input form properties" do
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

      it "persists updated loyalty indicators transparently inside the account records" do
        visit "/manage-loyalty-cards"

        within("#form-user-1") do
          fill_in "stamp_count", with: 7
          click_button "Save"
        end

        expect(DB[:Accounts].where(user_id: 1).get(:stamp_count)).to eq(7)
      end

      it "allows baristas to explicitly strip stamp counters down to zero" do
        visit "/manage-loyalty-cards"

        within("#form-user-1") do
          fill_in "stamp_count", with: 0
          click_button "Save"
        end

        expect(DB[:Accounts].where(user_id: 1).get(:stamp_count)).to eq(0)
      end
    end

    describe "Order Queue and Documentation Generation" do
      it "displays tracking data within the drink management queue layout" do
        visit "/order-management/barista"
        expect(current_path).to eq("/order-management/barista")
      end

      it "marks an order as completed via POST action and redirects" do
        order_id = DB[:Orders].first[:order_id]
        page.driver.submit :post, '/order-management/barista', { order_id: order_id }
        
        expect(current_path).to eq("/order-management/barista")
        expect(DB[:Orders].where(order_id: order_id).get(:is_completed)).to be true
      end

      it "generates a shipping documentation PDF successfully via inline browser calls" do
        order_id = DB[:Orders].first[:order_id]
        visit "/generate-label/#{order_id}"
        
        expect(page.driver.response.headers['Content-Type']).to eq('application/pdf')
        expect(page.driver.response.headers['Content-Disposition']).to include("attachment; filename=\"Label_#{order_id}.pdf\"")
      end

      it "generates a return validation PDF from post request submissions" do
        order_id = DB[:Orders].first[:order_id]
        page.driver.submit :post, "/generate-return/#{order_id}", {}
        
        expect(page.driver.response.headers['Content-Type']).to eq('application/pdf')
        expect(page.driver.response.headers['Content-Disposition']).to include("attachment; filename=\"Return_Label_#{order_id}.pdf\"")
      end
    end

    describe "Ticket and Refund Management Panels" do
      before do
        # Seed an unresolved ticket and a refund ticket to ensure routing pages resolve
        DB[:Tickets].insert(user_id: 1, ticket_type: 'General', ticket_content: 'Issue', ticket_resolved: false)
        DB[:Tickets].insert(user_id: 1, ticket_type: 'Refund', ticket_content: 'Money back', ticket_resolved: false)
      end

      it "can access the core ticketing interface dashboards" do
        visit "/user-tickets"
        expect(current_path).to eq("/user-tickets")
      end

      it "can access an individual ticket layout profile" do
        ticket_id = DB[:Tickets].where(ticket_type: 'General').first[:ticket_id]
        visit "/ticket/#{ticket_id}"
        expect(current_path).to eq("/ticket/#{ticket_id}")
      end

      it "resolves a ticket via POST submission and redirects" do
        ticket_id = DB[:Tickets].where(ticket_type: 'General').first[:ticket_id]
        page.driver.submit :post, "/resolve-ticket/#{ticket_id}", {}
        
        expect(current_path).to eq("/user-tickets")
        expect(DB[:Tickets].where(ticket_id: ticket_id).get(:ticket_resolved)).to be true
      end

      it "can access specialized financial refund workflow dashboards" do
        visit "/refund-tickets"
        expect(current_path).to eq("/refund-tickets")
      end

      it "can access individual refund resolve profiles" do
        ticket_id = DB[:Tickets].where(ticket_type: 'Refund').first[:ticket_id]
        visit "/refund/#{ticket_id}"
        expect(current_path).to eq("/refund/#{ticket_id}")
      end

      it "resolves a refund ticket via POST submission and redirects" do
        ticket_id = DB[:Tickets].where(ticket_type: 'Refund').first[:ticket_id]
        page.driver.submit :post, "/refund/#{ticket_id}", {}
        
        expect(current_path).to eq("/refund-tickets")
        expect(DB[:Tickets].where(ticket_id: ticket_id).get(:ticket_resolved)).to be true
      end
    end
  end
end