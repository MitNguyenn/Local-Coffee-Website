require 'sequel'
require 'sqlite3'
# Connect to the database
DB = Sequel.sqlite("db.sqlite3")

# Table 1: Accounts
DB.create_table? :Accounts do
  primary_key :UserID
  String :First_Name
  String :Last_name
  String :email, unique: true, null: false
  String :hashedPassword
  String :Phone_number, size: 11
  String :Postal_address, size: 7
  String :Account_type # e.g., 'Admin', 'Customer'
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
  String :OrderContents
  String :Order_Type
  String :Payment_method
  Float :totalCost
end

# Table 4: Tickets
DB.create_table? :Tickets do
  primary_key :ticketID
  foreign_key :userID, :Accounts
  String :ticketType
  String :ticketContent
  FalseClass :ticketResolved, default: false
end

puts "Database tables initialized successfully!"
