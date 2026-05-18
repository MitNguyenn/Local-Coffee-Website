require 'spec_helper'

RSpec.describe 'Staff Portal', type: :feature do

  context "Given a user authenticated as a barista employee" do
    before(:each) do
      log_in_as('testbarista@bbc.com', 'testbarista@bbc.com')
      visit '/staff-portal'
    end

    context "When exploring basic fulfillment and ticketing actions" do
      it "Then routes securely into the barista order queue board" do
        click_link 'Order Management'
        expect(current_path).to eq('/order-management/barista')
        expect(page).to have_content('Barista Order Controls')
      end

      it "Then transfers focus onto customer search registries for in-store sales" do
        click_link 'Place User Order'
        expect(current_path).to eq('/place-order/find-user')
        expect(page).to have_content('Place Order - Select Customer')
      end 

      it "Then provides full interface access to consumer reward card structures" do
        click_link 'Loyalty Cards'
        expect(current_path).to eq('/manage-loyalty-cards')
        expect(page).to have_content('Manage Loyalty Cards')
      end

      it "Then enters the communication support ticket dashboard table layout" do
        click_link 'User Tickets'
        expect(current_path).to eq('/user-tickets')
        expect(page).to have_content('Open Tickets')
      end

      it "Then navigates directly to monetary return claim workspaces" do
        click_link 'Refunds'
        expect(current_path).to eq('/refund-tickets')
        expect(page).to have_content('Open Refunds')
      end

      it "Then outputs aggregate sales turnover results for the current day" do
        click_link 'Daily Summary'
        expect(current_path).to eq('/daily-summary')
        expect(page).to have_content('Daily Summary')
        expect(page).to have_content('Total Sales')
      end
    end
  end

  context "Given a user authenticated as a store manager" do
    before(:each) do
      log_in_as('testmanager@bbc.com', 'testmanager@bbc.com')
      visit '/staff-portal'
    end

    context "When evaluating standard operational node link targets" do
      it "Then routes securely into the barista order queue board" do
        click_link 'Order Management'
        expect(current_path).to eq('/order-management/barista')
        expect(page).to have_content('Barista Order Controls')
      end

      it "Then transfers focus onto customer search registries for in-store sales" do
        click_link 'Place User Order'
        expect(current_path).to eq('/place-order/find-user')
        expect(page).to have_content('Place Order - Select Customer')
      end 

      it "Then provides full interface access to consumer reward card structures" do
        click_link 'Loyalty Cards'
        expect(current_path).to eq('/manage-loyalty-cards')
        expect(page).to have_content('Manage Loyalty Cards')
      end

      it "Then enters the communication support ticket dashboard table layout" do
        click_link 'User Tickets'
        expect(current_path).to eq('/user-tickets')
        expect(page).to have_content('Open Tickets')
      end

      it "Then navigates directly to monetary return claim workspaces" do
        click_link 'Refunds'
        expect(current_path).to eq('/refund-tickets')
        expect(page).to have_content('Open Refunds')
      end

      it "Then outputs aggregate sales turnover results for the current day" do
        click_link 'Daily Summary'
        expect(current_path).to eq('/daily-summary')
        expect(page).to have_content('Daily Summary')
        expect(page).to have_content('Total Sales')
      end
    end

    context "When utilizing administrative backoffice monitoring modules" do
      it "Then opens the financial metrics performance console framework" do
        click_link 'Metrics'
        expect(current_path).to eq('/metrics')
        expect(page).to have_content('Managerial Analytics')
      end

      it "Then accesses physical inventory metrics for raw coffee stock rows" do
        click_link 'Bean Stocks'
        expect(current_path).to eq('/bean-stock-management')
        expect(page).to have_content('Ethiopian')
        expect(page).to have_content('Brazillian')
        expect(page).to have_content('Arabic')
      end

      it "Then opens the store promotional discounts configuration panel" do
        click_link 'Discount Management'
        expect(current_path).to eq('/manage-discounts')
        expect(page).to have_content('Manage Store Discounts')
      end
    end
  end

  context "Given a user authenticated as an administrator" do
    before(:each) do
      log_in_as('testadmin@bbc.com', 'testadmin@bbc.com')
      visit '/staff-portal'
    end

    context "When evaluating standard operational node link targets" do
      it "Then routes securely into the barista order queue board" do
        click_link 'Order Management'
        expect(current_path).to eq('/order-management/barista')
        expect(page).to have_content('Barista Order Controls')
      end

      it "Then transfers focus onto customer search registries for in-store sales" do
        click_link 'Place User Order'
        expect(current_path).to eq('/place-order/find-user')
        expect(page).to have_content('Place Order - Select Customer')
      end 

      it "Then provides full interface access to consumer reward card structures" do
        click_link 'Loyalty Cards'
        expect(current_path).to eq('/manage-loyalty-cards')
        expect(page).to have_content('Manage Loyalty Cards')
      end

      it "Then enters the communication support ticket dashboard table layout" do
        click_link 'User Tickets'
        expect(current_path).to eq('/user-tickets')
        expect(page).to have_content('Open Tickets')
      end

      it "Then navigates directly to monetary return claim workspaces" do
        click_link 'Refunds'
        expect(current_path).to eq('/refund-tickets')
        expect(page).to have_content('Open Refunds')
      end

      it "Then outputs aggregate sales turnover results for the current day" do
        click_link 'Daily Summary'
        expect(current_path).to eq('/daily-summary')
        expect(page).to have_content('Daily Summary')
        expect(page).to have_content('Total Sales')
      end
    end

    context "When utilizing administrative backoffice monitoring modules" do
      it "Then opens the financial metrics performance console framework" do
        click_link 'Metrics'
        expect(current_path).to eq('/metrics')
        expect(page).to have_content('Managerial Analytics')
      end

      it "Then accesses physical inventory metrics for raw coffee stock rows" do
        click_link 'Bean Stocks'
        expect(current_path).to eq('/bean-stock-management')
        expect(page).to have_content('Ethiopian')
        expect(page).to have_content('Brazillian')
        expect(page).to have_content('Arabic')
      end

      it "Then opens the store promotional discounts configuration panel" do
        click_link 'Discount Management'
        expect(current_path).to eq('/manage-discounts')
        expect(page).to have_content('Manage Store Discounts')
      end
    end

    context "When executing system level data and user privilege mutations" do
      it "Then loads the primary registration table registry for standard customers" do
        click_link 'User Accounts'
        expect(current_path).to eq('/manage-accounts')
        expect(page).to have_content('Account Management')
      end

      it "Then opens the backoffice directory managing staff and internal profiles" do
        click_link 'Employee Accounts'
        expect(current_path).to eq('/employee-accounts')
        expect(page).to have_content('Account Management')
      end

      it "Then surfaces profiles marked problematic within the flagged user view index" do
        click_link 'Flagged Accounts'
        expect(current_path).to eq('/flagged-accounts')
        expect(page).to have_content('Flagged Accounts')
      end

      it "Then routes securely into the master administration order control center" do
        click_link 'Admin Orders'
        expect(current_path).to eq('/order-management/administrator')
        expect(page).to have_content('Admin Order Controls')
      end
    end
  end
end