require 'spec_helper'

RSpec.describe AnalyzeData do
  # Create a dummy class to isolate the module under test
  include described_class
  let(:now) { Time.now }

  describe '#analyze_sales_data' do
    context 'when evaluating production seed layout directly' do
      it 'calculates precise aggregations based on seeded entries' do
        result = analyze_sales_data(30)
        current_month = now.strftime('%B')

        expect(result[:total_sales]).to eq(10.33)
        expect(result[:avg_order_value]).to eq(5.17)
        expect(result[:monthly_sales]).to eq({ current_month => 10.33 })
      end

      it 'counts total accounts cleanly across seeded configurations' do
        result = analyze_sales_data(30)
        
        expect(result[:total_accounts]).to eq(27)
      end

      it 'applies correct structural string translations to seeded product profiles' do
        result = analyze_sales_data(30)
        products = result[:top_products]

        expect(products).to include({ name: 'Latte', units_sold: 1 })
        expect(products).to include({ name: 'Arabic', units_sold: 1 })
      end

      it 'accounts for string-casing variances when categorizing total sales' do
        result = analyze_sales_data(30)
        categories = result[:sales_by_category]

        expect(categories['Drinks']).to eq(0)
        expect(categories['Coffee Beans']).to eq(0)
      end
    end
  end
end