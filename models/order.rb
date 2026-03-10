class Order < Sequel::Model(:Orders)
  set_primary_key :OrderID

  # Data flow helper to handle the real (float) totalCost from PDF
  def self.create_order(user_id, contents, cost, type)
    create(
      UserID: user_id, 
      OrderContents: contents, 
      totalCost: cost, 
      OrderType: type
    )
  end
end
