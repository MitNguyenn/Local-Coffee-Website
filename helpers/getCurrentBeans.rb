# Helper functions for retrieving current coffee bean inventory.

module GetBeans
  def get_bean_data(origin)
    DB[:Beans].where(origin: origin).first
  end

  def get_bean_stock
    current_bean_stock = {}
    raw_data = DB[:Beans].all

    raw_data.each do |row|
      current_bean_stock[row[:origin]] = {
        current_stock: row[:stock_mass],
        price_per_250g: row[:price_per_250g].to_f
      }
    end

    current_bean_stock
  end

  def update_bean_stock(origin, new_bean_data)
    record = DB[:Beans].where(origin: origin)
    if record.first
      record.update(
        origin: new_bean_data[:new_origin],
        stock_mass: new_bean_data[:new_stock],
        price_per_250g: new_bean_data[:new_price_per_250g]
      )
      true
    else
      false
    end
  end
end