class orderObject < Sequel::Model(:orders)
  def self.create_order(user_id, ticket_id, total_price)
    create(user_id: user_id, ticket_id: ticket_id, total_price: total_price)
  end
end