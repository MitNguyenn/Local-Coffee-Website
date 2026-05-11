require 'spec_helper'

RSpec.describe "Order" do
  describe ".create_order" do
    it "creates an order with the given attributes" do
      # Use the UserID seeded in spec_functions.rb
      user_id = 10000001
      
      contents = "Coffee, Donut"
      cost = 5.50
      type = "Pickup"

      new_order = Order.create_order(user_id, contents, cost, type)

      expect(new_order).to be_a(Order)
      expect(new_order.UserID).to eq(user_id)
      expect(new_order.OrderContents).to eq(contents)
      expect(new_order.totalCost).to eq(cost)
      expect(new_order.OrderType).to eq(type)
    end
  end
end
