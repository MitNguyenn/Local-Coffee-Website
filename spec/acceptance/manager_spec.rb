# Manager Spec file.

require 'spec_helper'

RSpec.describe "ManagerController", type: :feature do

  context "Given an unauthenticated visitor" do
    context "When attempting to access the performance metrics page" do
      it "Then redirects back onto the home root path" do
        visit "/metrics"
        expect(page).to have_current_path("/")
      end
    end
  end

  context "Given a user authenticated as a regular customer" do
    before(:each) do
      log_in_as('testcust', 'testcust')
    end

    context "When trying to access the bean stock management desk" do
      it "Then redirects back onto the home root path" do
        visit "/bean-stock-management"
        expect(page).to have_current_path("/")
      end
    end
  end

  context "Given a user authenticated as a barista staff employee" do
    before(:each) do
      log_in_as('testbarista', 'testbarista')
    end

    context "When trying to open the corporate discount settings panel" do
      it "Then redirects back onto the home root path" do
        visit "/manage-discounts"
        expect(page).to have_current_path("/")
      end
    end
  end

  context "Given a user authenticated as a store manager" do
    before(:each) do
      log_in_as('testmanager', 'testmanager')
    end

    context "When requesting core manager interface domains" do
      it "Then opens the performance metrics analytics view successfully" do
        visit "/metrics"
        expect(page).to have_current_path("/metrics")
      end

      it "Then accesses the bean inventory database dashboard grid layout" do
        visit "/bean-stock-management"
        expect(page).to have_current_path("/bean-stock-management")
        expect(page).to have_content("Ethiopian")
      end

      it "Then loads isolated editing templates targeting individual bean profiles" do
        visit "/bean-update/Ethiopian"
        expect(page).to have_current_path("/bean-update/Ethiopian")
      end

      it "Then opens the store promotional discounts configuration environment" do
        visit "/manage-discounts"
        expect(page).to have_current_path("/manage-discounts")
        expect(page).to have_content("Manage Store Discounts")
      end

      it "Then opens the primary beverage price configuration page" do
        visit "/edit-drink-details"
        expect(page).to have_current_path("/edit-drink-details")
      end
    end

    context "When updating inventory records inside the stock controller" do
      it "Then alters persistent attribute definitions and displays the main inventory panel" do
        visit "/bean-update/Ethiopian"

        fill_in "new_origin", with: "Ethiopian Private Reserve"
        fill_in "new_stock", with: "18.5"
        fill_in "new_price_per_250g", with: "9.45"
        click_button "Save Inventory Changes"

        expect(page).to have_current_path("/bean-stock-management")
        
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

        expect(page).to have_current_path("/manage-discounts")
        
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

        expect(page).to have_current_path("/manage-discounts")
        
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

        expect(page).to have_current_path("/manage-discounts")
        expect(DB[:Discounts].where(discount_id: discount_id).first).to be_nil
      end
    end

    context "When modifying primary catalog rates inside the drink workflow desk" do
      before do
        DB[:Drinks].update(regular_price: 0.0)
      end

      it "Then executes updates matching pricing target formulas cleanly" do
        form_payload = { "prices[]" => DB[:Drinks].map.with_index { |_, i| (5.40 + i).to_s } }

        page.driver.post "/update-drink-details", form_payload

        visit page.driver.response.headers['Location']

        expect(page).to have_current_path("/edit-drink-details")

        drinks = DB[:Drinks].all
        drinks.each_with_index do |drink, i|
          expect(drink[:regular_price].to_f).to eq(5.40 + i)
        end
      end
    end
  end
end