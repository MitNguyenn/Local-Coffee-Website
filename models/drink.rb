class Drink < Sequel::Model(:Drinks)
  set_primary_key [:BeanID, :Beverage]
  many_to_one :bean # A drink belongs to a specific bean type
end