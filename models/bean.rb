# Bean model representing coffee bean inventory items.

class Bean < Sequel::Model(:Beans)
  set_primary_key :origin
end
