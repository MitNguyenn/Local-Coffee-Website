require 'sequel'
require 'sqlite3'
require 'json'

DB = Sequel.sqlite("db/db.sqlite3")

DB.drop_table?(:Tickets, :Orders, :Beans, :Accounts)

DB.create_table? :Accounts do
  Integer   :UserID, primary_key: true
  String    :FirstName
  String    :LastName
  DateTime  :Date_of_birth, null: true
  Integer   :StampCount, default: 0
  String    :email, unique: true, null: false
  String    :hashedPassword
  String    :PhoneNumber, size: 11
  String    :Postcode, size: 7
  String    :Address
  String    :AccountType, default: 'customer'
  DateTime  :Created_At, default: Sequel::CURRENT_TIMESTAMP
  DateTime  :Recent_Login, default: Sequel::CURRENT_TIMESTAMP
  TrueClass :Flagged, default: false
  DateTime  :Flagged_At, default: nil
  TrueClass :Suspended, default: false
end

DB.create_table? :Beans do
  Integer :BeanID, primary_key: true
  String  :Name
  Double  :Price # base price (price for 250g pack)
  Integer :CurrentStock
end

DB.create_table? :BeanOrigins do
  String :Origin, primary_key: true
end

DB.create_table? :BeanRoasts do
  String: Roast, primary_key: true 
end

DB.create_table? :Drinks do
  Integer :DrinkID, primary_key: true
  String  :Beverage
  Double  :Price, size: [10, 2]
  String  :Description
end

DB.create_table? :DrinkSizePriceMarkups do
  String :Size, primary_key: true
  Double :Markup
end

DB.create_table? :MilkTypes do
  String :Type, primary_key: true
  Double :Price, size: [10, 2]
end

DB.create_table? :Orders do
  primary_key :OrderID
  foreign_key :UserID, :Accounts, on_delete: :cascade
  String      :OrderType
  String      :PaymentMethod
  Double      :TotalCost, size: [10, 2]
  DateTime    :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  String      :Destination, default: 'In-Store'
  TrueClass   :IsCompleted, default: false
  String      :payment_status, default: 'Pending'
end

DB.create_table? :OrderItems do
  primary_key :OrderItemID
  foreign_key :OrderID, :Orders, on_delete: :cascade
  
  Integer :ProductID  # could be drinkID or beanID
  String  :ProductType # "drink" or "bean"
  
  Integer :Quantity, default: 1
  Float   :PriceAtPurchase # in case prices change later
  
  String  :Milk, default: nil   # Null if item == beans
  String  :Size, default: nil   # 'regular'/'large' if item == drinks else weight item == beans
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
