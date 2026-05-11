require_relative "../spec_helper"

# Use a String here instead of the Constant AnalyzeData
RSpec.describe "AnalyzeData" do
  # This pulls the methods from your module into the test scope
  include AnalyzeData

  describe "#analyze_sales_data" do
    it "returns a hash of sales metrics" do
      # 1. Setup test data
      user_id = 101
      DB[:Accounts].insert(UserID: user_id, email: 'test@data.com', hashedPassword: '...', Created_At: Time.now)
      
      # Inserting an order with JSON content as per your schema
      DB[:Orders].insert(
        UserID: user_id, 
        totalCost: 50.0, 
        CreatedAt: Time.now, 
        OrderContents: '[{"item":"Espresso", "price":50.0}]'
      )

      # 2. Call the method
      metrics = analyze_sales_data

      # 3. Assertions
      expect(metrics).to be_a(Hash)
      expect(metrics[:total_sales]).to eq(50.0)
      expect(metrics).to have_key(:avg_order_value)
      expect(metrics).to have_key(:top_products)
      expect(metrics).to have_key(:sales_by_category)
      expect(metrics).to have_key(:monthly_sales)
      expect(metrics).to have_key(:total_accounts)
      expect(metrics).to have_key(:monthly_signups_change)
    end
  end
end
