require 'json'

module MyOrders
  def fetch_current_orders(user_id)
    orders = DB[:Orders]
      .where(UserID: user_id, is_completed: false)
      .order(Sequel.desc(:created_at))
      .all

    parse_contents(orders)
  end

  def fetch_past_orders(user_id)
    orders = DB[:Orders]
      .where(UserID: user_id, is_completed: true)
      .order(Sequel.desc(:created_at))
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
