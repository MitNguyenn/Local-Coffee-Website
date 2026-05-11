RSpec.describe AnalyzeData do
  include described_class

  describe "#analyze_sales_data" do
    it "returns a hash of sales metrics" do
      # Setup test data in DB[:Orders] and DB[:Accounts] as needed - NEEDS DOING

      metrics = analyze_sales_data

      expect(metrics).to be_a(Hash)
      expect(metrics).to have_key(:total_sales)
      expect(metrics).to have_key(:avg_order_value)
      expect(metrics).to have_key(:top_products)
      expect(metrics).to have_key(:sales_by_category)
      expect(metrics).to have_key(:monthly_sales)
      expect(metrics).to have_key(:total_accounts)
      expect(metrics).to have_key(:monthly_signups_change)

      # Additional assertions can be made based on the test data setup
    end
  end
  