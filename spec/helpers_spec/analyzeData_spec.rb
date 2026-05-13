require 'spec_helper'

RSpec.describe MyOrders, type: :helper do
  include described_class

  let(:user_id) { 10000001 }
    
    # We clear the specific test objects out of the database to guarantee clean targets
    DB[:OrderItems].delete
    DB[:Orders].delete

    # Insert an uncompleted current order containing a Drink item
    @order_id_current = DB[:Orders].insert(
      UserID: user_id, 
      IsCompleted: false, 
      OrderType: 'In-Store',
      PaymentMethod: 'Card',
      TotalCost: 4.40,
      payment_status: 'Pending'
    )
    DB[:OrderItems].insert(
      OrderID: @order_id_current, 
      ItemID: 'Latte', 
      ProductType: 'drink', 
      Quantity: 1, 
      Size: 'Large'
    )

    # Insert a completed past order containing a Bean item
    @order_id_past = DB[:Orders].insert(
      UserID: user_id, 
      IsCompleted: true, 
      OrderType: 'In-Store',
      PaymentMethod: 'Card',
      TotalCost: 8.20,
      payment_status: 'Paid'
    )
    DB[:OrderItems].insert(
      OrderID: @order_id_past, 
      ItemID: 'Ethiopian', 
      ProductType: 'bean', 
      Quantity: 2, 
      RoastLevel: 'Medium'
    )
  end

  describe "#fetch_current_orders" do
    it "returns only active uncompleted relational joined order objects" do
      current_orders = fetch_current_orders(user_id)
      
      expect(current_orders.any? { |o| o[:IsCompleted] == false }).to be true
      expect(current_orders.any? { |o| o[:IsCompleted] == true }).to be false
      
      order_item = current_orders.find { |o| o[:OrderID] == @order_id_current }
      expect(order_item).not_to be_nil
      expect(order_item[:ItemID]).to eq('Latte')
      expect(order_item[:Quantity]).to eq(1)
    end
  end

  describe "#fetch_past_orders" do
    it "returns only completed historical relational joined order objects" do
      past_orders = fetch_past_orders(user_id)
      
      expect(past_orders.any? { |o| o[:IsCompleted] == true }).to be true
      expect(past_orders.any? { |o| o[:IsCompleted] == false }).to be false
      
      order_item = past_orders.find { |o| o[:OrderID] == @order_id_past }
      expect(order_item).not_to be_nil
      expect(order_item[:ItemID]).to eq('Ethiopian')
      expect(order_item[:Quantity]).to eq(2)
    end
  end
end