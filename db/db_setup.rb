require 'sequel'
require 'sqlite3'
require 'json'

module DatabaseInitializer
  def self.create_tables(db_connection)
    db_connection.tables.each do |table| 
      db_connection.drop_table?(table)
    end

    db_connection.create_table? :Accounts do
      Integer :UserID, primary_key: true
      String :first_name
      String :last_name
      Integer :StampCount, default: 0
      String :email, unique: true, null: false
      String :hashed_password
      String :PhoneNumber, size: 11
      String :Postcode, size: 7
      String :Address
      String :AccountType, default: 'customer'
      DateTime :Created_At, default: Sequel::CURRENT_TIMESTAMP
      DateTime :Recent_Login, default: Sequel::CURRENT_TIMESTAMP
      TrueClass :Flagged, default: false
      DateTime  :Flagged_At, default: nil
      TrueClass :Suspended, default: false
    end

    db_connection.create_table? :Beans do
      String  :Origin, primary_key: true
      Double :StockMass 
      Double  :PricePer250g 
    end

    db_connection.create_table? :BeansPackWeightPriceMarkupMultipliers do
      Double :PackWeight, primary_key: true
      Double :MarkupMultiplier
    end

    db_connection.create_table? :BeanRoastLevels do
      String :RoastLevel, primary_key: true 
    end

    db_connection.create_table? :Drinks do
      String    :Beverage, primary_key: true
      TrueClass :ContainsMilk
      Double    :RegularPrice, size: [10, 2]
      String    :Description
    end

    db_connection.create_table? :DrinkSizePriceMarkupMultipliers do
      String :DrinkSize, primary_key: true
      Double :MarkupMultiplier
    end

    db_connection.create_table? :MilkTypes do
      String :MilkType, primary_key: true
      Double :Price, size: [10, 2]
    end

    db_connection.create_table? :Orders do
      primary_key :OrderID
      foreign_key :UserID, :Accounts, on_delete: :cascade
      String      :OrderType
      String      :PaymentMethod
      Double      :TotalCost, size: [10, 2]
      DateTime    :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
      String      :Location, default: 'In-Store'
      TrueClass   :IsCompleted, default: false
      String      :payment_status, default: 'Pending'
    end

    db_connection.create_table? :OrderItems do
      foreign_key :OrderID, :Orders, on_delete: :cascade
      String :ItemID 
      String :ProductType
      Integer :Quantity, default: 1
      Double :PackWeight, default: nil
      String :RoastLevel, default: nil
      String  :Milk, default: nil  
      String  :Size, default: nil
      primary_key [:OrderID, :ItemID]
    end

    db_connection.create_table? :Tickets do
      primary_key :ticketID
      foreign_key :UserID, :Accounts, on_delete: :cascade
      String      :TicketType
      String      :TicketContent
      FalseClass  :TicketResolved, default: false
      DateTime    :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
    end

    db_connection.create_table? :Audits do
      primary_key :AuditID
      foreign_key :orderID, :Orders, on_delete: :cascade
      String      :BeforeStatus
      String      :AfterStatus
      Text        :ChangeReason
      DateTime    :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
    end

    db_connection.create_table? :Discounts do
      primary_key :DiscountID
      String :DiscountName
      Double :DiscountMultiplier, default: 1.0
    end

    puts "Database tables initialized successfully"
  end
end