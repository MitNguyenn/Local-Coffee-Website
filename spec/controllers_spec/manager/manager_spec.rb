RSpec.describe "Manager visits pages", type: :feature do
  describe "Attempts to visit pages without valid credentials" do
    it "Attempt to visit metrics page" do
      visit "/metrics"
      expect(current_path).to eq("/")
    end

    it "Attempt to visit User-tickets page" do
      visit "/user-tickets"
      expect(current_path).to eq("/")
    end

    it "Attempt to visit Stock-management page" do
      visit "/stock-management"
      expect(current_path).to eq("/")
    end

    it "Attempt to visit discount management page" do
      visit "/manage-discounts"
      expect(current_path).to eq("/")
    end

    # NEW: Verify unauthorized blocks to the new bean dashboard
    it "Attempt to visit Bean-stock-management page" do
      visit "/bean-stock-management"
      expect(current_path).to eq("/")
    end

    # NEW: Verify unauthorized blocks to explicit item update endpoints
    it "Attempt to visit individual Bean-update page" do
      visit "/bean-update/Ethiopian"
      expect(current_path).to eq("/")
    end
  end

  context "Logged in as manager" do
    before(:each) do
      log_in_as('testmanager@bbc.com', 'testpass')
    end

    describe "Manager visits all pages" do
      it "can access the metrics page" do
        visit "/metrics"
        expect(current_path).to eq("/metrics")
        expect(page).to have_content("Managerial Analytics") 
      end

      it "can access the user-tickets page" do
        visit "/user-tickets"
        expect(current_path).to eq("/user-tickets")
      end

      it "can access the stock-management page" do
        visit "/bean-stock-management"
        expect(current_path).to eq("/bean-stock-management")
      end

      it "can visit discount management page" do
        visit "/manage-discounts"
        expect(current_path).to eq("/manage-discounts")
        expect(page).to have_content("Manage Store Discounts")
      end

      it "can access the bean stock management dashboard" do
        visit "/bean-stock-management"
        expect(current_path).to eq("/bean-stock-management")
        expect(page).to have_selector(".cs-mgt-title", text: "Bean Stock Management")
        expect(page).to have_content("Ethiopian")
        expect(page).to have_content("Brazillian")
      end

      it "can access individual bean update panels" do
        visit "/bean-update/Ethiopian"
        expect(current_path).to eq("/bean-update/Ethiopian")
        expect(page).to have_selector(".cs-mgt-title", text: "Update Profile: Ethiopian")
        expect(page).to have_field("new_stock", with: "25.0")
      end
    end

    describe "Manager discount interface elements" do
      it "displays discounts formatted with percentage calculation rules" do
        visit "/manage-discounts"
        
        within(".discount-list") do
          expect(page).to have_selector(".discount-item")
          expect(page).to have_content("Discount Name")
        end
      end
    end

    describe "Manager bean modification workflow" do
      it "modifies and preserves updated inventory weights in the system database" do
        visit "/bean-update/Ethiopian"

        fill_in "new_origin", with: "Ethiopian Reserve"
        fill_in "new_stock", with: "21.75"
        fill_in "new_price_per_250g", with: "9.99"
        
        click_button "Save Inventory Changes"

        expect(current_path).to eq("/bean-stock-management")
        expect(page).to have_content("Ethiopian Reserve")
        expect(page).to have_content("21.75 kg")
        expect(page).to have_content("£9.99")

        updated_bean = DB[:Beans].where(origin: "Ethiopian Reserve").first
        expect(updated_bean).not_to be_nil
        expect(updated_bean[:stock_mass]).to eq(21.75)
      end
    end
  end
end