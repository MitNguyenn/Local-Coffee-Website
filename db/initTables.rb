require 'sequel'
require 'sqlite3'
# Connect to the database
DB = Sequel.sqlite("db/db.sqlite3")

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

# Create Beans Table
DB.create_table? :Beans do
  primary_key :BeanID
  String :Name, null: false
  String :Roast
  Decimal :PricePerBag, size: [10, 2]
  Integer :CurrentStock, default: 0
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
