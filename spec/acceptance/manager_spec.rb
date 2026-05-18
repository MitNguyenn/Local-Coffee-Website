require 'spec_helper'

RSpec.describe "ManagerController", type: :feature do

  context "Given an unauthenticated visitor" do
    context "When attempting to access the performance metrics page" do
      it "Then redirects back onto the home root path" do
        visit "/metrics"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as a regular customer" do
    before(:each) do
      log_in_as('testcust@bbc.com', 'testcust@bbc.com')
    end

    context "When trying to access the bean stock management desk" do
      it "Then redirects back onto the home root path" do
        visit "/bean-stock-management"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as a barista staff employee" do
    before(:each) do
      log_in_as('testbarista@bbc.com', 'testbarista@bbc.com')
    end

    context "When trying to open the corporate discount settings panel" do
      it "Then redirects back onto the home root path" do
        visit "/manage-discounts"
        expect(current_path).to eq("/")
      end
    end
  end

  context "Given a user authenticated as a store manager" do
    before(:each) do
      log_in_as('testmanager@bbc.com', 'testmanager@bbc.com')
    end

    context "When requesting core manager interface domains" do
      it "Then opens the performance metrics analytics view successfully" do
        visit "/metrics"
        expect(current_path).to eq("/metrics")
      end

      it "Then accesses the bean inventory database dashboard grid layout" do
        visit "/bean-stock-management"
        expect(current_path).to eq("/bean-stock-management")
        expect(page).to have_content("Ethiopian")
      end

      it "Then loads isolated editing templates targeting individual bean profiles" do
        visit "/bean-update/Ethiopian"
        expect(current_path).to eq("/bean-update/Ethiopian")
      end

      it "Then opens the store promotional discounts configuration environment" do
        visit "/manage-discounts"
        expect(current_path).to eq("/manage-discounts")
        expect(page).to have_content("Manage Store Discounts")
      end

      it "Then opens the primary beverage price configuration page" do
        visit "/edit-drink-details"
        expect(current_path).to eq("/edit-drink-details")
      end
    end

    context "When updating inventory records inside the stock controller" do
      it "Then alters persistent attribute definitions and displays the main inventory panel" do
        visit "/bean-update/Ethiopian"

        fill_in "new_origin", with: "Ethiopian Private Reserve"
        fill_in "new_stock", with: "18.5"
        fill_in "new_price_per_250g", with: "9.45"
        click_button "Save Inventory Changes"

        expect(current_path).to eq("/bean-stock-management")
        
        updated_bean = DB[:Beans].where(origin: "Ethiopian Private Reserve").first
        expect(updated_bean).not_to be_nil
        expect(updated_bean[:stock_mass]).to eq(18.5)
        expect(updated_bean[:price_per_250g]).to eq(9.45)
      end
    end

    context "When adding structural records into the discount subsystem" do
      it "Then registers the promotional profile and lists it in the view layout" do
        visit "/manage-discounts"

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
    end

    context "When altering existing promotional rule properties inline" do
      it "Then saves new multiplier fields safely inside isolated target rows" do
        discount_id = DB[:Discounts].first[:discount_id]

        visit "/manage-discounts"

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
    end

    context "When choosing to drop an active promotional rule configuration" do
      it "Then purges the entry data record completely from persistent tables" do
        discount_id = DB[:Discounts].first[:discount_id]

        visit "/manage-discounts"
        click_button "deletediscount-#{discount_id}"

        expect(current_path).to eq("/manage-discounts")
        expect(DB[:Discounts].where(discount_id: discount_id).first).to be_nil
      end
    end

    context "When modifying primary catalog rates inside the drink workflow desk" do
      it "Then executes updates matching pricing target formulas cleanly" do
        visit "/edit-drink-details"
        click_button "Change Details"
        
        new_price = DB[:Drinks].first
        expect(new_price[:regular_price].to_f).to eq(4.4)
      end
    end
  end
end