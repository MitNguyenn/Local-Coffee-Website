require 'json'

module AnalyzeData
  def analyze_sales_data
    metrics = {}
    all_orders = DB[:Orders].all

    # 1. Financials
    metrics[:total_sales] = DB[:Orders].sum(:totalCost) || 0
    metrics[:avg_order_value] = DB[:Orders].avg(:totalCost) || 0

    # 2. Top 3 Ranking Logic
    product_counts = Hash.new(0)
    all_orders.each do |order|
      begin
        contents = JSON.parse(order[:OrderContents] || "{}")
        if contents.is_a?(Hash)
          contents.each { |name, qty| product_counts[name] += qty.to_i }
        elsif contents.is_a?(Array)
          contents.each { |item| product_counts[item["name"]] += item["qty"].to_i }
        end
      rescue JSON::ParserError
        next
      end
    end

    # Sort descending and take top 3
    metrics[:top_products] = product_counts.sort_by { |_, qty| -qty }.first(3)

    # 3. Sales by Order Type
    metrics[:sales_by_category] = DB[:Orders]
      .group(:OrderType)
      .select(:OrderType, Sequel.function(:sum, :totalCost).as(:total))
      .to_hash(:OrderType, :total)

    # 4. Monthly Timeline
    metrics[:monthly_sales] = DB[:Orders]
      .select(
        Sequel.function(:strftime, '%Y-%m', :CreatedAt).as(:month),
        Sequel.function(:sum, :totalCost).as(:total)
      )
      .group(:month)
      .order(:month)
      .to_hash(:month, :total)

    metrics
  end
end
