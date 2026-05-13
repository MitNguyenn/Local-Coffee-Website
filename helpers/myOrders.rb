module MyOrders
  def fetch_current_orders(user_id)
    DB[:Orders]
      .join(:OrderItems, OrderID: :OrderID)
      .where(UserID: user_id, IsCompleted: false)
      .all
  end

  def fetch_past_orders(user_id)
    DB[:Orders]
      .join(:OrderItems, OrderID: :OrderID)
      .where(UserID: user_id, IsCompleted: true)
      .all
  end
  
  def get_stats(user_id)
    orders = DB[:Orders]
      .join(:OrderItems, OrderID: :OrderID)
      .where(UserID: user_id)
      .all

    account = DB[:Accounts].where(UserID: user_id).first
    stamp_count = account ? account[:StampCount].modulo(10) : 0

    total_num_coffee = orders.select { |item| item[:ProductType] == 'drink' }.sum { |item| item[:Quantity] }
    total_num_beans  = orders.select { |item| item[:ProductType] == 'bean' }.sum { |item| item[:Quantity] }
    until_next_discount = 10 - stamp_count

    return {
      "stamp_count" => stamp_count,
      "total_num_coffee" => total_num_coffee,
      "total_num_beans" => total_num_beans,
      "until_next_discount" => until_next_discount
    }
  end
end
