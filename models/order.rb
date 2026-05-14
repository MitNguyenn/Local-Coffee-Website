class Order < Sequel::Model(:Orders)
  set_primary_key :order_id

  # Data flow helper to handle the real (float) totalCost from PDF
  def self.create_order(userID, contents, cost, type)
    create(
      user_id: userID, 
      OrderContents: contents, 
      totalCost: cost, 
    )
  end
end
