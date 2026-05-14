require 'spec_helper'

RSpec.describe MyOrders, type: :helper do
  include described_class

  let(:user_id) { 1 }

  describe "#fetch_current_orders" do
    it "returns active uncompleted orders matching relational item profiles" do
      current_orders = fetch_current_orders(user_id)

      expected_current_orders = DB[:Orders]
        .join(:OrderItems, order_id: :order_id)
        .where(user_id: user_id, is_completed: false)
        .all

      expect(current_orders).to eq(expected_current_orders)
    end
  end

  describe "#fetch_past_orders" do
    it "returns finalized historical orders matching relational item profiles" do
      past_orders = fetch_past_orders(user_id)

      expected_past_orders = DB[:Orders]
        .join(:OrderItems, order_id: :order_id)
        .where(user_id: user_id, is_completed: true)
        .all

      expect(past_orders).to eq(expected_past_orders)
    end
  end

  describe "#get_stats" do
    it "returns stats for users stamp count, total number of coffee ordered and orders until next discount" do
      user = DB[:Accounts].where(user_id: user_id).first

      orders = DB[:Orders]
        .join(:OrderItems, order_id: :order_id)
        .where(user_id: user_id)
        .all

      user_stats = get_stats(user_id)
      
      expected_stamp_count = user[:stamp_count]
      expect(user_stats["stamp_count"]).to eq(expected_stamp_count)

      expected_total_num_coffee = orders.select { |item| item[:product_type] == 'drink' }.sum { |item| item[:quantity] }
      expect(user_stats["total_num_coffee"]).to eq(expected_total_num_coffee)

      expected_total_beans = orders.select { |item| item[:product_type] == 'bean' }.sum { |item| item[:quantity] }
      expect(user_stats["total_num_beans"]).to eq(expected_total_beans)

      expected_until_next_discount = 10 - (expected_stamp_count % 10)
      expect(user_stats["until_next_discount"]).to eq(expected_until_next_discount)
    end
  end
end