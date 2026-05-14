require 'spec_helper'

RSpec.describe MyOrders, type: :helper do
  include described_class

  let(:user_id) { 10000001 }

  before(:each) do
    
    DB[:OrderItems].delete
    DB[:Orders].delete

    @order_id_current = DB[:Orders].insert(
      user_id: user_id, 
      is_completed: false, 
      payment_method: 'Card',
      total_cost: 4.40,
      payment_status: 'Pending'
    )
    DB[:OrderItems].insert(
      order_id: @order_id_current, 
      item_id: 'Latte', 
      product_type: 'drink', 
      quantity: 1, 
      size: 'Large'
    )

    @order_id_past = DB[:Orders].insert(
      user_id: user_id, 
      is_completed: true, 
      payment_method: 'Card',
      total_cost: 8.20,
      payment_status: 'Paid'
    )
    DB[:OrderItems].insert(
      order_id: @order_id_past, 
      item_id: 'Ethiopian', 
      product_type: 'bean', 
      quantity: 2, 
      roast_level: 'Medium'
    )
  end

  describe "#fetch_current_orders" do
    it "returns only active uncompleted relational joined order objects" do
      current_orders = fetch_current_orders(user_id)
      
      expect(current_orders.any? { |o| o[:is_completed] == false }).to be true
      expect(current_orders.any? { |o| o[:is_completed] == true }).to be false
      
      order_item = current_orders.find { |o| o[:order_id] == @order_id_current }
      expect(order_item).not_to be_nil
      expect(order_item[:item_id]).to eq('Latte')
      expect(order_item[:quantity]).to eq(1)
    end
  end

  describe "#fetch_past_orders" do
    it "returns only completed historical relational joined order objects" do
      past_orders = fetch_past_orders(user_id)
      
      expect(past_orders.any? { |o| o[:is_completed] == true }).to be true
      expect(past_orders.any? { |o| o[:is_completed] == false }).to be false
      
      order_item = past_orders.find { |o| o[:order_id] == @order_id_past }
      expect(order_item).not_to be_nil
      expect(order_item[:item_id]).to eq('Ethiopian')
      expect(order_item[:quantity]).to eq(2)
    end
  end
end