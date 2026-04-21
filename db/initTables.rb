require 'sequel'
require 'sqlite3'
require 'json'

# Connect to the database
DB = Sequel.sqlite("db/db.sqlite3")

# 1. Clear existing data (optional, prevents duplicates if you run it twice)
DB.drop_table?(:Tickets, :Orders, :Beans, :Accounts)

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
end

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
  String :OrderType
  String :PaymentMethod
  Double :TotalCost, size: [10, 2]
  DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  String :Destination, default: 'In-Store'
  TrueClass :IsCompleted, default: false
end

DB.create_table? :OrderItems do
  foreign_key :OrderID, :Orders
  String :ItemType
  Integer :ItemID 

  Integer :Quantity

  primary_key [:OrderID, :ItemType, :ItemID]
end

DB.create_table? :Tickets do
  primary_key :ticketID
  foreign_key :UserID, :Accounts
  String :TicketType
  String :TicketContent
  FalseClass :TicketResolved, default: false
  DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
end

puts "Database tables initialized successfully!"
