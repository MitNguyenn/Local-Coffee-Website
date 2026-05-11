RSpec.describe Order do
  let(:order) { Order.new }

  describe "#create_order" do
    it "creates an order with the given attributes" do
      userID = 1
      contents = "Coffee, Donut"
      cost = 5.50
      type = "Pickup"

      new_order = Order.create_order(userID, contents, cost, type)

      expect(new_order.UserID).to eq(userID)
      expect(new_order.OrderContents).to eq(contents)
      expect(new_order.totalCost).to eq(cost)
      expect(new_order.OrderType).to eq(type)
    end
  end
end
