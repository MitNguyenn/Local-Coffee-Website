module MyOrdersHelper
  def fetch_current_orders(user_id)
    DB[:Orders]
      .where(UserID: user_id, is_completed: false)
      .order(Sequel.desc(:OrderDate))
      .all
  end

  def fetch_past_orders(user_id)
    DB[:Orders]
      .where(UserID: user_id, is_completed: true)
      .order(Sequel.desc(:OrderDate))
      .all
  end
end