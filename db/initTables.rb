require 'sequel'
require 'sqlite3'
require 'json'

# Connect to the database
DB = Sequel.sqlite("db.sqlite3")

# 1. Clear existing data (optional, prevents duplicates if you run it twice)
DB.drop_table?(:Tickets, :Orders, :Beans, :Accounts)

# 2. Create tables (if they don't exist)
# Table 1: Accounts
DB.create_table? :Accounts do
  Integer :UserID, primary_key: true
  String :FirstName
  String :LastName
  Integer :StampCount, default: 0, null: false
  String :email, unique: true, null: false
  String :hashedPassword
  String :PhoneNumber, size: 11
  String :Postcode, size: 7
  String :Address
  String :AccountType, default: 'customer'
end

# Create Beans Table
DB.create_table? :Beans do
  primary_key :BeanID
  String :Name
  String :Type 
  String :Roast 
  Integer :PackWeight
  Double :Price
  Integer :CurrentStock
end

# Create Drinks Table with Composite Key
DB.create_table? :Drinks do
  Integer :BeanID
  String :Beverage
  String :Size
  Decimal :Price, size: [10, 2]
  
  # Define the Composite Primary Key
  primary_key [:BeanID, :Beverage]
  
  # Link to the Beans table
  foreign_key [:BeanID], :Beans
end

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

puts "Database tables initialized successfully!"
