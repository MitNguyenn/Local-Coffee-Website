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
    end
  end
end
