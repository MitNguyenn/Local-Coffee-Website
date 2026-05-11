require 'bcrypt'
require 'json'
DB = Sequel.connect("sqlite://db/db.sqlite3")

def spec_before
  #Wipe every table in the database
  DB.tables.each do |table|
    # Skip internal sqlite metadata tables
    next if table == :sqlite_sequence
    DB[table].delete
  end

  #reset tables
  create_tables
  seed_data
end

def create_tables
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

end

def seed_data
  # 1. Seed Accounts
  # Use a fixed ID for the test user so you can reference it in Orders/Tickets
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

  # 2. Seed Beans
  DB[:Beans].insert(
    BeanID: 1,
    Name: 'Ethiopian Yirgacheffe',
    Type: 'Arabica',
    Roast: 'Light',
    PackWeight: 250,
    Price: 8.50,
    CurrentStock: 50
  )

  # 3. Seed Drinks
  DB[:Drinks].insert(
    DrinkID: 1,
    Beverage: 'Flat White',
    Price: 3.50,
    Description: 'Smooth double shot with microfoam'
  )

  # 4. Seed Orders
  # Note: OrderContents is stored as a JSON string
  order_items = [{ item: "Flat White", qty: 2, price: 7.00 }].to_json
  
  DB[:Orders].insert(
    UserID: 10000001,
    OrderContents: order_items,
    OrderType: 'In-Person',
    PaymentMethod: 'Card',
    totalCost: 7.00,
    Location: 'In-Store',
    payment_status: 'Paid'
  )

  # 5. Seed Tickets
  DB[:Tickets].insert(
    UserID: 10000001,
    TicketType: 'Support',
    TicketContent: 'Need help with my loyalty stamps.',
    TicketResolved: false
  )
  
  puts "Database seeded with test data!"
end
