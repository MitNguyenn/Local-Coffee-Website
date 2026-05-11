require 'json'

module AnalyzeData
  def analyze_sales_data
    metrics = {}
    all_orders = DB[:Orders].all

    metrics[:total_sales] = DB[:Orders].sum(:totalCost) || 0
    metrics[:avg_order_value] = DB[:Orders].avg(:totalCost) || 0

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

    metrics[:top_products] = product_counts.sort_by { |_, qty| -qty }.first(3)

    metrics[:sales_by_category] = DB[:Orders]
      .group(:OrderType)
      .select(:OrderType, Sequel.function(:sum, :totalCost).as(:total))
      .to_hash(:OrderType, :total)

    metrics[:monthly_sales] = DB[:Orders]
      .select(
        Sequel.function(:strftime, '%Y-%m', :CreatedAt).as(:month),
        Sequel.function(:sum, :totalCost).as(:total)
      )
      .group(:month)
      .order(:month)
      .to_hash(:month, :total)

    metrics[:total_accounts] = DB[:Accounts].count

    monthly_signups = DB[:Accounts]
      .select(
        Sequel.function(:strftime, '%Y-%m', :Created_At).as(:month),
        Sequel.function(:count, :UserID).as(:count)
      )
      .group(:month)
      .order(:month)
      .to_hash(:month, :count)

    metrics[:monthly_signups_change] = {}
    previous_count = 0
    monthly_signups.each do |month, count|
      change = count - previous_count
      metrics[:monthly_signups_change][month] = {
        signups: count,
        change: change
      }
      previous_count = count
    end

    metrics
  end
end
