RSpec.describe MyOrders, type: :helper do
  include described_class

  let(:user_id) { 10000001 }

  before do
    DB[:Orders].insert(UserID: user_id, IsCompleted: false, CreatedAt: Time.now - 3600, OrderContents: '{"item":"book","quantity":1}')
    DB[:Orders].insert(UserID: user_id, IsCompleted: true, CreatedAt: Time.now - 7200, OrderContents: '{"item":"pen","quantity":2}')
  end

  describe "#fetch_current_orders" do
    it "returns current orders for the user" do
      current_orders = fetch_current_orders(user_id)
      expect(current_orders.any? { |o| o[:IsCompleted] == false }).to be true
      
      order = current_orders.find do |o| 
        contents = o[:OrderContents]
        contents.is_a?(Hash) ? contents["item"] == "book" : JSON.parse(contents)["item"] == "book" rescue nil
      end
      expect(order).not_to be_nil
    end
  end

  describe "#fetch_past_orders" do
    it "returns past orders for the user" do
      past_orders = fetch_past_orders(user_id)
      expect(past_orders.any? { |o| o[:IsCompleted] == true }).to be true
    end
  end

  describe "#parse_contents" do
    it "parses JSON order contents into a hash" do
      orders = DB[:Orders].where(UserID: user_id).all
      parsed_orders = send(:parse_contents, orders)
      
      target = parsed_orders.find { |o| o[:OrderContents]["item"] == "book" rescue nil }
      expect(target[:OrderContents]).to eq({ "item" => "book", "quantity" => 1 })
    end

    it "handles invalid JSON gracefully" do
      DB[:Orders].insert(UserID: user_id, IsCompleted: false, CreatedAt: Time.now, OrderContents: 'invalid json')
      
      orders = DB[:Orders].where(UserID: user_id).all
      parsed_orders = send(:parse_contents, orders)
      expect(parsed_orders.last[:OrderContents]).to eq({})
    end
  end
end
