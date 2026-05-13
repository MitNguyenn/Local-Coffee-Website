module Discounts
  def get_current_discounts
    current_discounts = {}
    raw_data = DB[:Discounts].all
    
    raw_data.each do |row|
      current_discounts[row[:discount_name]] = {
        id: row[:discount_id],
        multiplier: row[:discount_multiplier].to_f # Aligned with schema change
      }
    end
    current_discounts
  end

  def update_discount(new_data)
    record = DB[:Discounts].where(discount_id: new_data[:discount_id])

    if record.first
      record.update(
        discount_name: new_data[:discount_name],
        discount_multiplier: new_data[:discount_mult].to_f # Aligned with schema change
      )
      true
    else
      false
    end
  end
  
  def create_discount(discount_name, discount_mult)
    DB[:Discounts].insert(
      discount_name: discount_name,
      discount_multiplier: discount_mult.to_f
    )
  end

  def delete_discount(discount_id)
    rows_affected = DB[:Discounts].where(discount_id: discount_id).delete
    rows_affected > 0
  end
end