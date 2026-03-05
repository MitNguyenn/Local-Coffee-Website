class ticketObject < Sequel::Model(:ticket)
  def self.create_ticket(user_id, bean_id, quantity)
    create(user_id: user_id, bean_id: bean_id, quantity: quantity)
  end
end