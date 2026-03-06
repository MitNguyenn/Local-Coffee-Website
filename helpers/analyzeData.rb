module AnalyzeData
  def analyze_sales_data(sales_data)

    total_sales = sales_data.reduce(0) { |sum, order| sum + order[:total_amount] }
    
    # Example: Group sales by product category
    sales_by_category = sales_data.group_by { |order| order[:category] }.transform_values do |orders|
      orders.reduce(0) { |sum, order| sum + order[:total_amount] }
    end

    {
      total_sales: total_sales,
      sales_by_category: sales_by_category
      # Add more insights as needed
    }
  end
end