require 'sequel'
require 'sqlite3'
require 'json'

DB = Sequel.sqlite("db/db.sqlite3")

DB.tables.each do | table | 
  DB.drop_table?(table)
end

DB.create_table? :Accounts do
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

DB.create_table? :Beans do
  String  :Origin, primary_key: true
  Double :StockMass 
  Double  :PricePer250g 
end

DB.create_table? :BeansPackWeightPriceMarkupMultipliers do
  Double :PackWeight, primary_key: true
  Double :MarkupMultiplier
end

DB.create_table? :BeanRoastLevels do
  String :RoastLevel, primary_key: true 
end

DB.create_table? :Drinks do
  String    :Beverage, primary_key: true
  TrueClass :ContainsMilk
  Double    :RegularPrice, size: [10, 2]
  String    :Description
end

DB.create_table? :DrinkSizePriceMarkupMultipliers do
  String :DrinkSize, primary_key: true
  Double :MarkupMultiplier
end

DB.create_table? :MilkTypes do
  String :MilkType, primary_key: true
  Double :Price, size: [10, 2]
end

DB.create_table? :Orders do
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

DB.create_table? :OrderItems do
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

DB.create_table? :Tickets do
  primary_key :ticketID
  foreign_key :UserID, :Accounts, on_delete: :cascade
  String      :TicketType
  String      :TicketContent
  FalseClass  :TicketResolved, default: false
  DateTime    :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
end

DB.create_table? :Audits do
  primary_key :AuditID
  foreign_key :orderID, :Orders, on_delete: :cascade
  String      :BeforeStatus
  String      :AfterStatus
  Text        :ChangeReason
  DateTime    :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
end

puts "Database tables initialized successfully"

# Denormalized version of beans data
# DB.create_table? :Beans do
#   String  :Origin, primary_key: true
#   Integer :Weight
#   String  :Roast
#   Double  :Price, size: [10, 2] # base price
# end

# # if the price of Ethiopian 250g pack changes, other packs will also change in price
# DB.create_table? :BeansPackWeightPriceMarkupMultipliers do
#   Integer :Weight, primary_key: true
#   Double  :MarkupMultiplier
# end

# DB.create_table? :BeansPackStock do
#   foreign_key :Origin, :Beans, on_delete: :cascade
#   foreign_key :PackWeight, :BeanPackWeights, on_delete: :cascade
#   Integer :Stock

#   primary_key [:Origin, :PackWeight]
# end
