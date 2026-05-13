require 'spec_helper'

RSpec.describe MyOrders, type: :helper do
  include described_class

  let(:user_id) { 10000001 }

  before do
    DB[:OrderItems].delete
    DB[:Orders].delete

    order_id_1 = DB[:Orders].insert(
      UserID: user_id, 
      IsCompleted: false, 
      CreatedAt: Time.now - 3600,
      OrderType: 'In-Store',
      PaymentMethod: 'Card',
      TotalCost: 4.40
    )
    DB[:OrderItems].insert(
      OrderID: order_id_1, 
      ItemID: 'Latte', 
      ProductType: 'drink', 
      Quantity: 1, 
      Size: 'Large'
    )

    order_id_2 = DB[:Orders].insert(
      UserID: user_id, 
      IsCompleted: true, 
      CreatedAt: Time.now - 7200,
      OrderType: 'In-Store',
      PaymentMethod: 'Card',
      TotalCost: 8.20
    )
    DB[:OrderItems].insert(
      OrderID: order_id_2, 
      ItemID: 'Ethiopian', 
      ProductType: 'bean', 
      Quantity: 2, 
      RoastLevel: 'Medium'
    )
  end

  describe "#fetch_current_orders" do
    it "returns active uncompleted orders matching relational item profiles" do
      current_orders = fetch_current_orders(user_id)
      expect(current_orders.any? { |o| o[:IsCompleted] == false }).to be true
      
      order = current_orders.find { |o| o[:ItemID] == "Latte" }
      expect(order).not_to be_nil
      expect(order[:Quantity]).to eq(1)
    end
  end

  describe "#fetch_past_orders" do
    it "returns finalized historical orders matching relational item profiles" do
      past_orders = fetch_past_orders(user_id)
      expect(past_orders.any? { |o| o[:IsCompleted] == true }).to be true
      
      order = past_orders.find { |o| o[:ItemID] == "Ethiopian" }
      expect(order).not_to be_nil
      expect(order[:Quantity]).to eq(2)
    end
  end
end