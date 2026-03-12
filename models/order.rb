class Order < Sequel::Model(:Orders)
  set_primary_key :OrderID

  # Data flow helper to handle the real (float) totalCost from PDF
  def self.create_order(userID, contents, cost, type)
    create(
      UserID: userID, 
      OrderContents: contents, 
      totalCost: cost, 
      OrderType: type
    )
  end
end
