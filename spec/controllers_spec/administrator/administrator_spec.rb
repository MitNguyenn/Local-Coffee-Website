RSpec.describe "Admin Management", type: :feature do
  let(:admin_id)    { 99999999 }
  let(:customer_id) { 10000001 }

  before do
    # Global Login for Admin
    visit '/log-in'
    fill_in 'email', with: 'admin@coffee.com'
    fill_in 'password', with: 'SecretPassword123'
    click_button 'Log In'
  end

  describe "Account Management Table" do
    it "displays all seeded accounts with correct IDs" do
      visit "/manage-accounts"
        expect(page).to have_content("#10000001")
        expect(page).to have_content("John Doe")
        expect(page).to have_content("customer")
      end
    end

    it "has a functional search input field" do
      visit "/manage-accounts"
      expect(page).to have_field("accountSearch")
    end

    it "navigates to the edit page via the table button" do
      visit "/manage-accounts"
      within(".acc-view__row", text: "john@example.com") do
        click_link "Edit Account"
      end
      expect(current_path).to eq("/edit-account/10000001")
    end
  end

  describe "Metrics and Sales" do
    it "displays the metrics page with total sales" do
      visit "/metrics"
      # Seeded order was 7.00. 
      # Ensure your analyze_sales_data helper returns a Hash!
      expect(page).to have_content("7.0") 
    end
  end
end
