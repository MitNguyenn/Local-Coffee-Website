RSpec.describe "AnalyzeData" do
  include AnalyzeData

  describe "#analyze_sales_data" do
    it "returns correct metrics including seeded data" do
      # 1. Setup specific test data
      user_id = 10000001 # Use seeded John Doe
      test_amount = 50.0
      
      DB[:Orders].insert(
        UserID: user_id, 
        totalCost: test_amount, 
        CreatedAt: Time.now, 
        OrderContents: '[{"item":"Espresso", "price":50.0}]'
      )

      # 2. Call the method
      metrics = analyze_sales_data

      # 3. Assertions
      # Seed (£7.00) + Test (£50.00) = £57.00
      expect(metrics[:total_sales]).to eq(57.0)
      expect(metrics[:total_accounts]).to be >= 1
      expect(metrics).to include(:avg_order_value, :monthly_signups_change)
    end
  end
end
