require 'spec_helper'

RSpec.describe AnalyzeData do
  # We include the module into the test execution context
  include AnalyzeData 
  
  let(:now) { Time.now }

  describe '#analyze_sales_data' do
    before(:each) do
      spec_before # Clear the random seeds
      
      # 1. Seed exactly 27 accounts for the account count test
      27.times do |i|
        DB[:Accounts].insert(email: "user#{i}@test.com", Created_At: now)
      end

      # 2. Seed specific Orders for Financial tests
      # Total: £40.00 | Avg: £20.00
      DB[:Orders].insert(order_id: 1, totalCost: 30.00, CreatedAt: now, user_id: 1)
      DB[:Orders].insert(order_id: 2, totalCost: 10.00, CreatedAt: now, user_id: 1)

      # 3. Seed OrderItems for Category and Product tests
      DB[:OrderItems].insert(order_id: 1, item_id: 'Ethiopian', Category: 'Coffee Beans', Quantity: 2, Price: 20.00)
      DB[:OrderItems].insert(order_id: 2, item_id: 'Latte', Category: 'Drinks', Quantity: 1, Price: 10.00)
    end

    it 'calculates precise aggregations (Total & Avg)' do
      result = analyze_sales_data(30)
      
      expect(result[:total_sales]).to eq(40.0)
      expect(result[:avg_order_value]).to eq(20.0)
    end

    it 'counts total accounts accurately' do
      result = analyze_sales_data(30)
      expect(result[:total_accounts]).to eq(27)
    end

    it 'identifies top products by name' do
      result = analyze_sales_data(30)
      # result[:top_products] returns [[name, qty], ...] based on your previous code
      product_names = result[:top_products].map { |p| p[0] }
      
      expect(product_names).to include("Ethiopian", "Latte")
    end

    it 'groups sales by category correctly' do
      result = analyze_sales_data(30)
      categories = result[:sales_by_category]

      # Note: Based on your code, if there are sales, these won't be 0
      expect(categories['Drinks']).to eq(10.0)
      expect(categories['Coffee Beans']).to eq(20.0)
    end
  end
end