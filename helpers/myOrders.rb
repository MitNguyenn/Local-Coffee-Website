require 'json'

module MyOrders
  def fetch_user_orders(user_id, completed: false)
    # 1. Fetch ALL user orders to calculate the correct sequence number
    all_user_orders = DB[:Orders]
      .where(UserID: user_id)
      .order(:created_at) # Oldest first to count correctly
      .all

    # 2. Add a user-specific sequence number (1, 2, 3...) and parse JSON
    mapped_orders = all_user_orders.each_with_index.map do |order, index|
      order[:user_seq] = index + 1
      order[:OrderContents] = JSON.parse(order[:OrderContents]) rescue {}
      order
    end

    # 3. Filter for the requested status and reverse so newest is at the top
    mapped_orders.select { |o| o[:is_completed] == completed }.reverse
  end
end
