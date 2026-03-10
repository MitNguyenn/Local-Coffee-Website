require 'json'

module MyOrders
  def fetch_current_orders(user_id)
    orders = DB[:Orders]
      .where(UserID: user_id, IsCompleted: false)
      .order(Sequel.desc(:CreatedAt))
      .all

    parse_contents(orders)
  end

  def fetch_past_orders(user_id)
    orders = DB[:Orders]
      .where(UserID: user_id, IsCompleted: true)
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
