# Order model representing customer transactions.

class Order < Sequel::Model(:Orders)
  set_primary_key :order_id
end
