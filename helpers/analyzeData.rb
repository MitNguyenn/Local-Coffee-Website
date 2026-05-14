module AnalyzeData
  def analyze_sales_data(days_ago = 30)
    now = Time.now
    start_date = now - (days_ago * 24 * 60 * 60)
    prev_month_start = start_date - (30 * 24 * 60 * 60)
    current_month_name = now.strftime("%B")
    
    recent_orders = DB[:Orders].where(Sequel.lit('created_at >= ?', start_date))
    
    total_sales = recent_orders.sum(:total_cost) || 0.0
    order_count = recent_orders.count
    avg_order = order_count > 0 ? (total_sales / order_count).round(2) : 0.0

    this_month_signups = DB[:Accounts].where(created_at: start_date..now).count
    last_month_signups = DB[:Accounts].where(created_at: prev_month_start..start_date).count
    
    signup_change = last_month_signups > 0 ? 
      (((this_month_signups - last_month_signups).to_f / last_month_signups) * 100).round(1) : 0.0

    recent_items = DB[:OrderItems]
      .join(:Orders, order_id: :order_id)
      .where(Sequel.lit('Orders.created_at >= ?', start_date))

    top_products = recent_items
      .select(
        Sequel.lit("CASE 
          WHEN product_type = 'Drink' AND size IS NOT NULL THEN item_id || ' (' || size || ')'
          WHEN product_type = 'Bean' AND roast_level IS NOT NULL THEN item_id || ' ' || roast_level || ' Roast'
          ELSE item_id 
        END AS product_name"),
        Sequel.function(:sum, :quantity).as(:total_units)
      )
      .group(:product_name)
      .order(Sequel.desc(:total_units))
      .limit(5)
      .map { |row| { name: row[:product_name], units_sold: row[:total_units].to_i } }

    category_raw = recent_items
      .group(:product_type)
      .select(:product_type, Sequel.function(:sum, :quantity).as(:qty))
      .to_hash(:product_type, :qty)

    sales_by_category = {
      "Drinks" => category_raw["Drink"] || 0,
      "Coffee Beans" => category_raw["Bean"] || 0
    }

    {
      total_sales: total_sales.to_f.round(2),
      avg_order_value: avg_order.to_f.round(2),
      total_accounts: DB[:Accounts].count,
      monthly_signups_change: { 
        current_month_name => { signups: this_month_signups, change: signup_change } 
      },
      top_products: top_products, 
      sales_by_category: sales_by_category, 
      monthly_sales: { current_month_name => total_sales.to_f.round(2) }
    }
  end

    def get_common_orders(limit_count = 5)
    # 1. Pull the most recurrent groupings of exact customer selections
    frequent_combinations = DB[:OrderItems]
      .select(
        :item_id,
        :product_type,
        :milk,
        :size,
        :pack_weight,
        :roast_level,
        Sequel.function(:count, :order_id).as(:frequency_count)
      )
      .group(:item_id, :product_type, :milk, :size, :pack_weight, :roast_level)
      .order(Sequel.desc(:frequency_count))
      .limit(limit_count)
      .all

    # 2. Map payload arrays into legible, presentation-ready structural hash entries
    frequent_combinations.map do |row|
      # Format descriptive title names based strictly on the production category properties
      display_title = case row[:product_type]&.downcase
                      when 'drink'
                        "#{row[:size]} #{row[:item_id]} (#{row[:milk]} Milk)"
                      when 'bean'
                        "#{row[:item_id]} #{row[:roast_level]} Roast [#{row[:pack_weight].to_i}g]"
                      else
                        row[:item_id].to_s
                      end

      {
        item_id: row[:item_id],
        product_type: row[:product_type],
        specifications: {
          milk: row[:milk],
          size: row[:size],
          pack_weight: row[:pack_weight],
          roast_level: row[:roast_level]
        },
        display_name: display_title,
        order_frequency: row[:frequency_count].to_i
      }
    end
  end
end