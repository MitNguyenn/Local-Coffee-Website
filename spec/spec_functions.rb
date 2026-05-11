require 'bcrypt'
require 'json'

def spec_before
  DB.run("PRAGMA foreign_keys = OFF")

  DB.tables.each do |table|
    next if table == :sqlite_sequence
    DB[table].delete
  end

  DB.run("PRAGMA foreign_keys = ON")

  create_tables
  seed_data
end

def create_tables
  DB.create_table? :Accounts do
    Integer :UserID, primary_key: true
    String :FirstName
    String :LastName
    DateTime :Date_of_birth
    Integer :StampCount, default: 0
    String :email, unique: true, null: false
    String :hashedPassword
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

  DB.create_table? :Beans do
    Integer :BeanID, primary_key: true
    String :Name
    String :Type 
    String :Roast 
    Integer :PackWeight
    Double :Price
    Integer :CurrentStock
  end 

  DB.create_table? :Drinks do
    Integer :DrinkID, primary_key: true
    String :Beverage
    Double :Price, size: [10, 2]
    String :Description
  end

  DB.create_table? :Orders do
    primary_key :OrderID
    foreign_key :UserID, :Accounts
    String :OrderContents
    String :OrderType
    String :PaymentMethod
    Float :totalCost
    DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
    String :Location, default: 'In-Store'
    TrueClass :IsDelivered, default: false
    TrueClass :IsCompleted, default: false
    String :payment_status, default: 'Pending'
  end

  DB.create_table? :Tickets do
    primary_key :ticketID
    foreign_key :UserID, :Accounts
    String :TicketType
    String :TicketContent
    FalseClass :TicketResolved, default: false
    DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  end

  DB.create_table? :Audits do
    primary_key :AuditID
    foreign_key :orderID, :Orders
    String :BeforeStatus
    String :AfterStatus
    Text :ChangeReason
    DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  end
end

def seed_data
  password = BCrypt::Password.create('SecretPassword123')
  
  DB[:Accounts].insert(
    UserID: 10000001,
    FirstName: 'John',
    LastName: 'Doe',
    email: 'john@example.com',
    hashedPassword: password,
    PhoneNumber: '07123456789',
    Postcode: 'SW1A1AA',
    Address: '10 Ruby Lane',
    AccountType: 'customer'
  )

  DB[:Beans].insert(BeanID: 1, Name: 'Ethiopian Yirgacheffe', Type: 'Arabica', Roast: 'Light', PackWeight: 250, Price: 8.50, CurrentStock: 50)
  DB[:Drinks].insert(DrinkID: 1, Beverage: 'Flat White', Price: 3.50, Description: 'Smooth double shot')

  order_items = [{ item: "Flat White", qty: 2, price: 7.00 }].to_json
  DB[:Orders].insert(UserID: 10000001, OrderContents: order_items, OrderType: 'In-Person', totalCost: 7.00, payment_status: 'Paid')
  DB[:Tickets].insert(UserID: 10000001, TicketType: 'Support', TicketContent: 'Loyalty help', TicketResolved: false)
end