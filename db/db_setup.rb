# Database setup logic and connection helper definitions.

require 'sequel'
require 'sqlite3'
require 'json'

module DatabaseInitializer
  def self.create_tables(db_connection)
    db_connection.tables.each do |table| 
      db_connection.drop_table?(table)
    end

    db_connection.create_table? :Accounts do
      Integer :user_id, primary_key: true
      String :first_name
      String :last_name
      Integer :stamp_count, default: 0
      String :email, unique: true, null: false
      String :hashed_password
      String :phone_number, size: 11
      String :postcode, size: 7
      String :address
      String :account_type, default: 'customer'
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :recent_login, default: Sequel::CURRENT_TIMESTAMP
      TrueClass :flagged, default: false
      DateTime  :flagged_at, default: nil
      TrueClass :suspended, default: false
    end

    db_connection.create_table? :Beans do
      String  :origin, primary_key: true
      Double :stock_mass 
      Double  :price_per_250g 
    end

    db_connection.create_table? :BeansPackWeightPriceMarkupMultipliers do
      Double :pack_weight, primary_key: true
      Double :markup_multiplier
    end

    db_connection.create_table? :BeanRoastLevels do
      String :roast_level, primary_key: true 
    end

    db_connection.create_table? :Drinks do
      String    :beverage, primary_key: true
      TrueClass :contains_milk
      Double    :regular_price, size: [10, 2]
      String    :description
    end

    db_connection.create_table? :DrinkSizePriceMarkupMultipliers do
      String :drink_size, primary_key: true
      Double :markup_multiplier
    end

    db_connection.create_table? :MilkTypes do
      String :milk_type, primary_key: true
      Double :price, size: [10, 2]
    end

    db_connection.create_table? :Orders do
      primary_key :order_id
      foreign_key :user_id, :Accounts, on_delete: :cascade

      DateTime    :created_at, default: Sequel::CURRENT_TIMESTAMP

      String      :address, default:  '1 Coffee Lane'
      String      :postcode, default:  'S1 1AA'
      
      Double      :total_cost, size: [10, 2]
      TrueClass   :payment_is_completed, default: false

      TrueClass   :order_is_completed, default: false
    end

    db_connection.create_table? :OrderItems do
      foreign_key :order_id, :Orders, on_delete: :cascade
      String :item_id 
      String :product_type
      Integer :quantity, default: 1
      Double :pack_weight, default: nil
      String :roast_level, default: nil
      String  :milk_type, default: nil  
      String  :drink_size, default: nil
      primary_key [ :order_id, :item_id ]
    end

    db_connection.create_table? :Tickets do
      primary_key :ticket_id
      foreign_key :user_id, :Accounts, on_delete: :cascade
      String      :ticket_type
      String      :ticket_content
      FalseClass  :ticket_resolved, default: false
      DateTime    :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    db_connection.create_table? :Audits do
      primary_key :audit_id
      foreign_key :order_id, :Orders, on_delete: :cascade
      String      :before_status
      String      :after_status
      Text        :change_reason
      DateTime    :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    db_connection.create_table? :Discounts do
      primary_key :discount_id
      String :discount_name
      Double :discount_multiplier, default: 1.0
    end

    puts "Database tables initialized successfully"
  end
end
