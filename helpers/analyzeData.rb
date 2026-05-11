module AnalyzeData
  def analyze_sales_data(days_ago = 30)
    start_date = Time.now - (days_ago * 24 * 60 * 60)
    
    # Filter orders within the time range
    recent_orders = DB[:Orders].where { CreatedAt >= start_date }
    
    # Basic Metrics
    total_sales = recent_orders.sum(:totalCost) || 0.0
    order_count = recent_orders.count
    avg_order = order_count > 0 ? (total_sales / order_count).round(2) : 0.0

    # Monthly Trends (Current vs Previous)
    prev_month_start = start_date - (30 * 24 * 60 * 60)
    this_month_signups = DB[:Accounts].where { Created_At >= start_date }.count
    last_month_signups = DB[:Accounts].where(Created_At: prev_month_start..start_date).count
    
    signup_change = last_month_signups > 0 ? 
      (((this_month_signups - last_month_signups).to_f / last_month_signups) * 100).round(1) : 0.0

    {
      total_sales: total_sales.to_f.round(2),
      avg_order_value: avg_order,
      total_accounts: DB[:Accounts].count,
      monthly_signups_change: signup_change,
      # Placeholders for more complex logic if needed
      top_products: [], 
      sales_by_category: {},
      monthly_sales: {}
    }
  end
end
