module Discounts
  def get_current_discounts
    current_discounts = {}
    raw_data = DB[:Discounts].all
    
    raw_data.each do |row|
      current_discounts[row[:DiscountName]] = {
        id: row[:DiscountID],
        multiplier: row[:DiscountMultiplier].to_f # Aligned with schema change
      }
    end
    current_discounts
  end

  def update_discount(new_data)
    record = DB[:Discounts].where(DiscountID: new_data[:discount_id])

    if record.first
      record.update(
        DiscountName: new_data[:discount_name],
        DiscountMultiplier: new_data[:discount_mult].to_f # Aligned with schema change
      )
      true
    else
      false
    end
  end
  
  def create_discount(discount_name, discount_mult)
    DB[:Discounts].insert(
      DiscountName: discount_name,
      DiscountMultiplier: discount_mult.to_f
    )
  end

  def delete_discount(discount_id)
    rows_affected = DB[:Discounts].where(DiscountID: discount_id).delete
    rows_affected > 0
  end
end