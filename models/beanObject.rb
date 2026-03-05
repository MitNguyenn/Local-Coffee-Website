class BeanObject < Sequel::Model(:bean_instances)
  # Add any bean-specific validation or methods here
  def validate
    super
    errors.add(:bean_type, "is required") if !bean_type || bean_type.empty?
  end
end