module Discounts
  def get_current_discounts
    current_discounts = {}

    raw_data = DB[:Discounts].all
    
    raw_data.each do |row|
      current_discounts[row[:DiscountName]] = row[:DiscountMult].to_f
    end

    current_discounts
  end

  def update_discount(discount_id, new_multiplier)
    # Check if the targeted discount line row exists first
    record = DB[:Discounts].where(DiscountName: discount_name)

    if record.first
      record.update(DiscountMult: new_multiplier.to_f)
      true
    else
      false
    end
  end
end
