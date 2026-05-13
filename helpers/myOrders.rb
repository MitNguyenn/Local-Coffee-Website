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
end
