class Bean < Sequel::Model(:Beans)
  set_primary_key :BeanID
  one_to_many :drinks

  def validate
    super
    errors.add(:BeanType, "is required") if !BeanType || BeanType.empty?
    # Validates current stock is a number (integer in PDF)
    errors.add(:Current_stock, "must be a number") if Current_stock && !Current_stock.is_a?(Integer)
  end
end
