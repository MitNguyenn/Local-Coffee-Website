require 'spec_helper'

RSpec.describe "Order" do # Changed to String
  describe ".create_order" do # Use '.' for class methods
    it "creates an order with the given attributes" do
      # Ensure a User exists if your DB has foreign key constraints
      user_id = 1
      DB[:Accounts].insert(UserID: user_id, email: "test@test.com") rescue nil

      contents = "Coffee, Donut"
      cost = 5.50
      type = "Pickup"

      # Call the class method
      new_order = Order.create_order(user_id, contents, cost, type)

      # Assertions
      expect(new_order).to be_a(Order)
      expect(new_order.UserID).to eq(user_id)
      expect(new_order.OrderContents).to eq(contents)
      expect(new_order.totalCost).to eq(cost)
      expect(new_order.OrderType).to eq(type)
    end
  end
end
