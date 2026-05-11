require_relative "../spec_helper"

RSpec.describe "AnalyzeData" type: :helper do
  include AnalyzeData

  describe "#analyze_sales_data" do
    it "returns a hash of sales metrics" do
      user_id = 101
      DB[:Accounts].insert(
        UserID: user_id, 
        email: 'test@data.com', 
        hashed_password: '...', 
        Created_At: Time.now
      )
      
      DB[:Orders].insert(
        UserID: user_id, 
        totalCost: 50.0, 
        CreatedAt: Time.now, 
        OrderContents: '[{"item":"Espresso", "price":50.0}]'
      )

      metrics = analyze_sales_data

      expect(metrics).to be_a(Hash)
      # Now it will be exactly 50.0 because the table was empty
      expect(metrics[:total_sales]).to eq(50.0) 
      
      expect(metrics).to include(
        :avg_order_value, 
        :top_products, 
        :sales_by_category, 
        :monthly_sales, 
        :total_accounts, 
        :monthly_signups_change
      )
    end
  end
end
