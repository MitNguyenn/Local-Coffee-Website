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
        visit "/stock-management"
        expect(current_path).to eq("/stock-management")
      end

      it "can visit discount management page" do
        visit "/manage-discounts"
        expect(current_path).to eq("/manage-discounts")
        expect(page).to have_selector("h1.discount-page-title", text: "Manage Store Discounts")
      end
    end

    describe "Manager discount interface elements" do
      it "displays discounts formatted with percentage calculation rules" do
        # Assumes test mock payload includes a multiplier of 0.85
        visit "/manage-discounts"
        
        within(".discount-list") do
          expect(page).to have_selector(".discount-item")
          expect(page).to have_selector(".discount-percentage", text: "15% OFF")
        end
      end
    end
  end
end