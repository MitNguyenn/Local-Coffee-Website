RSpec.describe MyOrders do
  include described_class

  let(:user_id) { 1 }
  let(:orders_data) do
    [
      { UserID: user_id, IsCompleted: false, CreatedAt: Time.now - 3600, OrderContents: '{"item":"book","quantity":1}' },
      { UserID: user_id, IsCompleted: true, CreatedAt: Time.now - 7200, OrderContents: '{"item":"pen","quantity":2}' }
    ]
  end

  before do
    # 1. Clear tables in correct order (child then parent)
    DB[:Orders].delete 
    DB[:Accounts].delete

    # 2. CREATE THE USER FIRST to satisfy the Foreign Key constraint
    DB[:Accounts].insert(
      UserID: user_id, 
      email: 'test@example.com', 
      first_name: 'Test', 
      last_name: 'User', 
      password: 'password123456'
    )

    # 3. Now you can insert the orders
    orders_data.each { |order| DB[:Orders].insert(order) }
  end

  describe "#fetch_current_orders" do
    it "returns current orders for the user" do
      current_orders = fetch_current_orders(user_id)
      expect(current_orders.length).to eq(1)
      expect(current_orders.first[:IsCompleted]).to be(false)
      # Ensure your helper actually parses JSON, or this might need to be a string match
      expect(current_orders.first[:OrderContents]).to eq({ "item" => "book", "quantity" => 1 })
    end
  end

  describe "#fetch_past_orders" do
    it "returns past orders for the user" do
      past_orders = fetch_past_orders(user_id)
      expect(past_orders.length).to eq(1)
      expect(past_orders.first[:IsCompleted]).to be(true)
      expect(past_orders.first[:OrderContents]).to eq({ "item" => "pen", "quantity" => 2 })
    end
  end

  describe "#parse_contents" do
    it "parses JSON order contents into a hash" do
      orders = DB[:Orders].where(UserID: user_id).all
      parsed_orders = send(:parse_contents, orders)
      expect(parsed_orders.first[:OrderContents]).to eq({ "item" => "book", "quantity" => 1 })
    end

    it "handles invalid JSON gracefully" do
      # Note: This insert also requires the user to exist, which our 'before' block handles
      DB[:Orders].insert(UserID: user_id, IsCompleted: false, CreatedAt: Time.now, OrderContents: 'invalid json')
      orders = DB[:Orders].where(UserID: user_id).all
      parsed_orders = send(:parse_contents, orders)
      expect(parsed_orders.last[:OrderContents]).to eq({})
    end
  end
end
