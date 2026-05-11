require 'sequel'
require 'sqlite3'
require 'json'

DB = Sequel.sqlite("db/db.sqlite3")

DB.drop_table?(:Tickets, :Orders, :Beans, :Accounts)

DB.create_table? :Accounts do
  Integer :UserID, primary_key: true
  String :FirstName
  String :LastName
  DateTime :Date_of_birth, null: true
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
  DateTime :Flagged_At, default: nil
  TrueClass :Suspended, default: false
end

DB.create_table? :Beans do
  Integer :BeanID
  String :Name
  String :Type 
  String :Roast 
  Integer :PackWeight
  Double :Price
  Integer :CurrentStock
end 

DB.create_table? :Drinks do
  Integer :DrinkID
  String :Beverage
  Double :Price, size: [10, 2]
  String :Description

end

# DB.create_table? :SizePrices do
#   Integer :DrinkID
#   String :Size
#   Double :Price, size: [10, 2]
#   primary_key [:DrinkID, :Size]

#   foreign_key [:DrinkID], :Drinks
# end

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

puts "Database tables initialized successfully"
