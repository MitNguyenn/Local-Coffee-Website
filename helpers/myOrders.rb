require 'json'

module MyOrders
  def fetch_current_orders(userID)
    orders = DB[:Orders]
      .where(UserID: userID, IsCompleted: false)
      .order(Sequel.desc(:CreatedAt))
      .all

    parse_contents(orders)
  end

  def fetch_past_orders(userID)
    orders = DB[:Orders]
      .where(UserID: userID, IsCompleted: true)
      .order(Sequel.desc(:CreatedAt))
      .all

    parse_contents(orders)
  end

  private

  def parse_contents(orders)
    orders.map do |order|
      # Parse JSON string into Ruby Hash; defaults to empty hash on failure
      order[:OrderContents] = JSON.parse(order[:OrderContents]) rescue {}
      order
    end
  end
end
