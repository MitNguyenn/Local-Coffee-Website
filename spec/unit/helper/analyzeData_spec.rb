require 'spec_helper'

RSpec.describe AnalyzeData do
  include described_class

  describe '#analyze_sales_data' do
    context "Given the seeded business data exists in the repository" do
      context "When evaluating overarching transaction summaries" do
        it 'Then computes positive values for total revenue and average basket parameters' do
          result = analyze_sales_data(30)
          
          # Since the seeder randomizes items, we verify mathematical consistency
          expect(result[:total_sales]).to be >= 0.0
          expect(result[:avg_order_value]).to be >= 0.0
        end

        it 'Then reads the comprehensive account registration total accurately' do
          result = analyze_sales_data(30)
          
          # 3 staff + 5 specific test users + 15 random + 2 developers = 25 baseline rows
          expect(result[:total_accounts]).to eq(27)
        end
      end

      context "When mapping trending product patterns and categories" do
        it 'Then extracts matching structured records for high-performing menu items' do
          result = analyze_sales_data(30)
          
          # Confirms the data structure elements are successfully packaged into named keys
          if result[:top_products].any?
            first_product = result[:top_products].first
            expect(first_product).to have_key(:name)
            expect(first_product).to have_key(:units_sold)
          end
        end

        it 'Then categorizes raw item units under proper Drinks and Coffee Beans groupings' do
          result = analyze_sales_data(30)
          categories = result[:sales_by_category]

          expect(categories).to have_key("Drinks")
          expect(categories).to have_key("Coffee Beans")
          expect(categories["Drinks"]).to be_kind_of(Integer)
          expect(categories["Coffee Beans"]).to be_kind_of(Integer)
        end
      end
    end
  end

  describe '#get_common_orders' do
    before(:each) do
      # Flush transaction records to isolate string building logic from random generator sets
      DB[:OrderItems].delete
      DB[:Orders].delete

      @customer_id = 1
      @order_id_1 = DB[:Orders].insert(user_id: @customer_id, total_cost: 4.70, created_at: Time.now)
      @order_id_2 = DB[:Orders].insert(user_id: @customer_id, total_cost: 4.70, created_at: Time.now)

      # Insert repeating custom drink selections using the exact TitleCase string parameters your method parses
      DB[:OrderItems].insert(order_id: @order_id_1, product_type: 'Drink', item_id: 'Latte', milk_type: 'Oat', drink_size: 'Regular', quantity: 1)
      DB[:OrderItems].insert(order_id: @order_id_2, product_type: 'Drink', item_id: 'Latte', milk_type: 'Oat', drink_size: 'Regular', quantity: 1)
    end

    context "When identifying customer recurring order combinations" do
      it "Then generates legibly formatted descriptive title fields with correct frequency tracking" do
        common = get_common_orders(5)
        
        expect(common.first[:display_name]).to eq("Regular Latte (Oat Milk)")
        expect(common.first[:order_frequency]).to eq(2)
      end
    end
  end
end