module MyOrders
  def fetch_current_orders(user_id)
    DB[:Orders]
      .join(:OrderItems, order_id: :order_id)
      .where(user_id: user_id, is_completed: false)
      .all
  end

  def fetch_past_orders(user_id)
    DB[:Orders]
      .join(:OrderItems, order_id: :order_id)
      .where(user_id: user_id, is_completed: true)
      .all
  end
  
  def get_stats(user_id)
    orders = DB[:Orders]
      .join(:OrderItems, order_id: :order_id)
      .where(user_id: user_id)
      .all

    account = DB[:Accounts].where(user_id: user_id).first
    stamp_count = account ? account[:stamp_count].modulo(10) : 0

    total_num_coffee = orders.select { |item| item[:product_type] == 'drink' }.sum { |item| item[:quantity] }
    total_num_beans  = orders.select { |item| item[:product_type] == 'bean' }.sum { |item| item[:quantity] }
    until_next_discount = 10 - stamp_count

    stats = {
      "stamp_count" => stamp_count,
      "total_num_coffee" => total_num_coffee,
      "total_num_beans" => total_num_beans,
      "until_next_discount" => until_next_discount
    }
    
    stats
  end
end
