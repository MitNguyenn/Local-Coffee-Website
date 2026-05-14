require 'spec_helper'

RSpec.describe ManagerController, type: :feature do
  describe "Attempts to visit pages without valid credentials" do
    it "redirects an unauthenticated guest away from metrics" do
      visit "/metrics"
      expect(current_path).to eq("/")
    end

    it "redirects a plain customer away from bean stock management" do
      log_in_as('testcust@bbc.com', 'testpass')
      visit "/bean-stock-management"
      expect(current_path).to eq("/")
    end

    it "redirects a barista away from discount management" do
      log_in_as('testbarista@bbc.com', 'testpass')
      visit "/manage-discounts"
      expect(current_path).to eq("/")
    end
  end

  context "Logged in as manager" do
    before(:each) do
      log_in_as('testmanager@bbc.com', 'testpass')
    end

    describe "GET Routing Endpoints" do
      it "can access the core metrics analytics page" do
        visit "/metrics"
        expect(current_path).to eq("/metrics")
      end

      it "can access the bean stock dashboard layout" do
        visit "/bean-stock-management"
        expect(current_path).to eq("/bean-stock-management")
        expect(page).to have_content("Ethiopian")
      end

      it "can access an individual bean profile edit template" do
        visit "/bean-update/Ethiopian"
        expect(current_path).to eq("/bean-update/Ethiopian")
      end

      it "can access the current store discounts board" do
        visit "/manage-discounts"
        expect(current_path).to eq("/manage-discounts")
        expect(page).to have_content("Manage Store Discounts")
      end
    end

    describe "Inventory Component Management Flows" do
      it "updates bean metrics via field fill actions and redirects" do
        visit "/bean-update/Ethiopian"

        fill_in "new_origin", with: "Ethiopian Private Reserve"
        fill_in "new_stock", with: "18.5"
        fill_in "new_price_per_250g", with: "9.45"
        click_button "Save Inventory Changes"

        expect(current_path).to eq("/bean-stock-management")
        
        # Confirm underlying database state mutations
        updated_bean = DB[:Beans].where(origin: "Ethiopian Private Reserve").first
        expect(updated_bean).not_to be_nil
        expect(updated_bean[:stock_mass]).to eq(18.5)
        expect(updated_bean[:price_per_250g]).to eq(9.45)
      end
    end

    describe "Discount Subsystem Modifications" do
      it "creates a new promotional profile using explicit text entry" do
        visit "/manage-discounts"

        # Scopes form controls to isolate the unique create card structure
        within(".discount-create-card") do
          fill_in "discount_name", with: "Launch Special"
          fill_in "discount_mult", with: "0.80"
          click_button "Create Discount"
        end

        expect(current_path).to eq("/manage-discounts")
        
        saved_discount = DB[:Discounts].where(discount_name: "Launch Special").first
        expect(saved_discount).not_to be_nil
        expect(saved_discount[:discount_multiplier].to_f).to eq(0.80)
      end

      it "updates an active discount setting via structural inline elements" do
        discount_id = DB[:Discounts].first[:discount_id]

        visit "/manage-discounts"

        # Explicitly targets the individual ID row to isolate input contexts safely
        within("#discount-row-#{discount_id}") do
          fill_in "discount_name", with: "Late Spring Clearance"
          fill_in "discount_mult", with: "0.75"
          click_button "Save Changes"
        end

        expect(current_path).to eq("/manage-discounts")
        
        altered_discount = DB[:Discounts].where(discount_id: discount_id).first
        expect(altered_discount[:discount_name]).to eq("Late Spring Clearance")
        expect(altered_discount[:discount_multiplier].to_f).to eq(0.75)
      end

      it "purges a promotional discount rule completely from database tables" do
        discount_id = DB[:Discounts].first[:discount_id]

        visit "/manage-discounts"

        # Directly targets the explicit template delete ID to bypass sibling conflicts
        click_button "deletediscount-#{discount_id}"

        expect(current_path).to eq("/manage-discounts")
        expect(DB[:Discounts].where(discount_id: discount_id).first).to be_nil
      end
    end
  end
end