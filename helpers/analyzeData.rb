#inputs array of hashes of sales data, outputs hash of metrics for the metrics page
#metrics wanted = total sales, average order value, most popular product, sales by category, sales over time (daily/weekly/monthly)

module AnalyzeData
  def analyze_sales_data
    metrics = {}

    # 1. Total Sales
    metrics[:total_sales] = DB[:Orders].sum(:totalCost) || 0

    # 2. Average Order Value
    metrics[:avg_order_value] = DB[:Orders].avg(:totalCost) || 0

    # 3. Most Popular Product (by frequency in OrderContents)
    metrics[:most_popular_product] = DB[:Orders]
      .group_and_count(:OrderContents)
      .reverse_order(:count)
      .first&.[](:OrderContents)

    # 4. Sales by Category (using Order_Type)
    metrics[:sales_by_category] = DB[:Orders]
      .group(:Order_Type)
      .select(:Order_Type, Sequel.function(:sum, :totalCost).as(:total))
      .to_hash(:Order_Type, :total)

    # 5. Sales Over Time (Monthly example)
    # Note: SQLite date functions used here; adjust for Postgres/MySQL if needed
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

