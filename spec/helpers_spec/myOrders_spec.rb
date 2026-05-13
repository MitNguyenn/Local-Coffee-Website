require 'spec_helper'

RSpec.describe MyOrders, type: :helper do
  include described_class

  let(:user_id) { 10000001 }

  before do
    DB[:OrderItems].delete
    DB[:Orders].delete

    order_id_1 = DB[:Orders].insert(
      user_id: user_id, 
      is_completed: false, 
      created_at: Time.now - 3600,
      order_type: 'In-Store',
      payment_method: 'Card',
      total_cost: 4.40
    )
    DB[:OrderItems].insert(
      order_id: order_id_1, 
      item_id: 'Latte', 
      product_type: 'drink', 
      quantity: 1, 
      size: 'Large'
    )

    order_id_2 = DB[:Orders].insert(
      user_id: user_id, 
      is_completed: true, 
      created_at: Time.now - 7200,
      order_type: 'In-Store',
      payment_method: 'Card',
      total_cost: 8.20
    )
    DB[:OrderItems].insert(
      order_id: order_id_2, 
      item_id: 'Ethiopian', 
      product_type: 'bean', 
      quantity: 2, 
      roast_level: 'Medium'
    )
  end

  describe "#fetch_current_orders" do
    it "returns active uncompleted orders matching relational item profiles" do
      current_orders = fetch_current_orders(user_id)
      expect(current_orders.any? { |o| o[:is_completed] == false }).to be true
      
      order = current_orders.find { |o| o[:item_id] == "Latte" }
      expect(order).not_to be_nil
      expect(order[:quantity]).to eq(1)
    end
  end

  describe "#fetch_past_orders" do
    it "returns finalized historical orders matching relational item profiles" do
      past_orders = fetch_past_orders(user_id)
      expect(past_orders.any? { |o| o[:is_completed] == true }).to be true
      
      order = past_orders.find { |o| o[:item_id] == "Ethiopian" }
      expect(order).not_to be_nil
      expect(order[:quantity]).to eq(2)
    end
  end
end