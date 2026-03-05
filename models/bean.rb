class Bean < Sequel::Model(:Beans)
  set_primary_key :BeanID

  def validate
    super
    errors.add(:Bean_type, "is required") if !Bean_type || Bean_type.empty?
    # Validates current stock is a number (integer in PDF)
    errors.add(:Current_stock, "must be a number") if Current_stock && !Current_stock.is_a?(Integer)
  end
end
