require 'bcrypt'
require 'json'

def spec_before
  # 1. Force clean slate by dropping everything
  DB.run("PRAGMA foreign_keys = OFF")
  [:Audits, :Tickets, :Orders, :Drinks, :Beans, :Accounts].each do |table|
    DB.drop_table?(table)
  end
  DB.run("PRAGMA foreign_keys = ON")

  # 2. Re-create the schema
  create_tables
  
  # 3. Insert global seeds
  seed_data
end

def create_tables
  DB.create_table :Accounts do
    Integer :UserID, primary_key: true
    String :first_name
    String :last_name
    DateTime :Date_of_birth
    Integer :StampCount, default: 0
    String :email, unique: true, null: false
    String :hashedPassword, null: false
    String :PhoneNumber, size: 11
    String :Postcode, size: 7
    String :Address
    String :AccountType, default: 'customer'
    DateTime :Created_At, default: Sequel::CURRENT_TIMESTAMP
    DateTime :Recent_Login, default: Sequel::CURRENT_TIMESTAMP
    TrueClass :Flagged, default: false
    DateTime :Flagged_At
    TrueClass :Suspended, default: false
  end

  DB.create_table :Beans do
    Integer :BeanID, primary_key: true
    String :Name; String :Type; String :Roast; Integer :PackWeight
    Double :Price; Integer :CurrentStock
  end 

  DB.create_table :Drinks do
    Integer :DrinkID, primary_key: true
    String :Beverage; Double :Price; String :Description
  end

  DB.create_table :Orders do
    primary_key :OrderID
    foreign_key :UserID, :Accounts, on_delete: :cascade
    String :OrderContents; String :OrderType; String :PaymentMethod
    Float :totalCost; DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
    String :Location, default: 'In-Store'; TrueClass :IsDelivered, default: false
    TrueClass :IsCompleted, default: false; String :payment_status, default: 'Pending'
  end

  DB.create_table :Tickets do
    primary_key :ticketID
    foreign_key :UserID, :Accounts, on_delete: :cascade
    String :TicketType; String :TicketContent
    FalseClass :TicketResolved, default: false
    DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  end

  DB.create_table :Audits do
    primary_key :AuditID
    foreign_key :orderID, :Orders, on_delete: :cascade
    String :BeforeStatus; String :AfterStatus; Text :ChangeReason
    DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  end
end

def seed_data
  # Use cost: 4 for speed in tests
  pass = BCrypt::Password.create('SecretPassword123', cost: 4)
  
  DB[:Accounts].insert(UserID: 10000001, first_name: 'John', email: 'john@example.com', hashedPassword: pass)
  DB[:Beans].insert(BeanID: 1, Name: 'Ethiopian', Price: 8.50, CurrentStock: 50)
  DB[:Drinks].insert(DrinkID: 1, Beverage: 'Flat White', Price: 3.50)
end
