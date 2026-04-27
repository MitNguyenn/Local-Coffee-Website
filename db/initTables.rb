require 'sequel'
require 'sqlite3'
require 'json'

# Connect to the database
DB = Sequel.sqlite("db/db.sqlite3")

# 1. Clear existing data (optional, prevents duplicates if you run it twice)
DB.drop_table?(:Tickets, :Orders, :Beans, :Accounts)

# 2. Create tables (if they don't exist)
# Table 1: Accounts
DB.create_table? :Accounts do
  Integer :UserID, primary_key: true
  String :FirstName
  String :LastName
  Datetime :Date_of_birth, null: true
  Integer :StampCount, default: 0
  String :email, unique: true, null: false
  String :hashedPassword
  String :PhoneNumber, size: 11
  String :Postcode, size: 7
  String :Address
  String :AccountType, default: 'customer'
  Datetime :Created_At, default: Sequel::CURRENT_TIMESTAMP
end

# Create Beans Table
DB.create_table? :Beans do
  Integer :BeanID
  String :Name
  String :Type 
  String :Roast 
  Integer :PackWeight
  Double :Price
  Integer :CurrentStock

  primary_key [:BeanID]
end

# Create Drinks Table with Composite Key
DB.create_table? :Drinks do
  Integer :DrinkID
  String :Beverage
  Double :Price, size: [10, 2]
  String :Description
  
  primary_key [:DrinkID]
end

# DB.create_table? :SizePrices do
#   Integer :DrinkID
#   String :Size
#   Double :Price, size: [10, 2]
#   primary_key [:DrinkID, :Size]

#   foreign_key [:DrinkID], :Drinks
# end

# Table 3: Orders
DB.create_table? :Orders do
  primary_key :OrderID
  foreign_key :UserID, :Accounts
  String :OrderContents    # We will store a JSON string here
  String :OrderType       # 'In-Person' or 'Delivery'
  String :PaymentMethod
  Float :totalCost
  DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  String :Location, default: 'In-Store'
  TrueClass :IsDelivered, default: false
  TrueClass :IsCompleted, default: false
  String :payment_status, default: 'Pending'
end

# Table 4: Tickets
DB.create_table? :Tickets do
  primary_key :ticketID
  foreign_key :UserID, :Accounts
  String :TicketType
  String :TicketContent
  FalseClass :TicketResolved, default: false
  DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
end

# Table 5: Audits
DB.create_table? :Audits do
  primary_key :AuditID
  foreign_key :orderID, :Orders
  String :BeforeStatus,
  String :AfterStatus,
  Text :ChangeReason,
  DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
end

puts "Database tables initialized successfully!"
