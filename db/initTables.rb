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
  String :First_Name
  String :Last_name
  String :email, unique: true, null: false
  String :hashedPassword
  String :Phone_number, size: 11
  String :Postal_address, size: 7
  String :Account_type 
end

# Table 2: Beans
DB.create_table? :Beans do
  primary_key :BeanID
  String :Bean_type
  String :Bean_blend
  String :Bean_roast
  Integer :Current_stock
end

# Table 3: Orders
DB.create_table? :Orders do
  primary_key :OrderID
  foreign_key :UserID, :Accounts
  String :OrderContents    # We will store a JSON string here
  String :Order_Type       # 'In-Person' or 'Delivery'
  String :Payment_method
  Float :totalCost
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  String :location, default: 'In-Store'
  TrueClass :is_delivered, default: false
  TrueClass :is_completed, default: false
end


# Table 4: Tickets
DB.create_table? :Tickets do
  primary_key :ticketID
  foreign_key :UserID, :Accounts
  String :ticketType
  String :ticketContent
  FalseClass :ticketResolved, default: false
end

puts "Database tables initialized successfully!"
