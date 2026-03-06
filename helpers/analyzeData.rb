require 'json'

module AnalyzeData
  def analyze_sales_data
    metrics = {}
    # Fetch all orders once to avoid multiple database hits for complex Ruby processing
    all_orders = DB[:Orders].all

    # 1. Total Sales
    metrics[:total_sales] = DB[:Orders].sum(:totalCost) || 0

    # 2. Average Order Value
    metrics[:avg_order_value] = DB[:Orders].avg(:totalCost) || 0

    # 3. FIXED: Most Popular Product (Parsing JSON)
    # We create a hash where default value is 0: { "BeanName" => total_qty }
    product_counts = Hash.new(0)
    
    all_orders.each do |order|
      begin
        # Parse the JSON string into a Ruby Hash
        contents = JSON.parse(order[:OrderContents] || "{}")
        
        contents.each do |item_name, quantity|
          product_counts[item_name] += quantity.to_i
        end
      rescue JSON::ParserError
        next # Skip if data is malformed
      end
    end

    # Get the key (name) with the highest value (quantity)
    metrics[:most_popular_product] = product_counts.max_by { |name, qty| qty }&.first || "No Sales Yet"

    # 4. Sales by Category (using Order_Type)
    metrics[:sales_by_category] = DB[:Orders]
      .group(:Order_Type)
      .select(:Order_Type, Sequel.function(:sum, :totalCost).as(:total))
      .to_hash(:Order_Type, :total)

    # 5. Sales Over Time (Monthly)
    metrics[:monthly_sales] = DB[:Orders]
      .select(
        Sequel.function(:strftime, '%Y-%m', :created_at).as(:month),
        Sequel.function(:sum, :totalCost).as(:total)
      )
      .group(:month)
      .order(:month)
      .to_hash(:month, :total)

    metrics
  end
end
