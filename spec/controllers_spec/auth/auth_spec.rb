RSpec.describe "User Vists generic auth pages" do
  context "User is logged in" do
    before(:each) do
      log_in_as("john@example.com", "_p_")
    end

    it "User logs out" do
      visit "/log-out"

      expect(current_path).to eq("/log-in")
    end

    it "User goes to forget password page" do
      visit "/forgot"

      expect(current_path).to eq("/forgot")
      expect(page).to have_content("Forgot Password")
    end
  end
end