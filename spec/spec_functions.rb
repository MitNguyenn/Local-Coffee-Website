require 'bcrypt'
require 'json'

def spec_before
  # 1. Force clean slate by dropping everything
  DB.run("PRAGMA foreign_keys = OFF")
  [:Audits, :Tickets, :Orders, :Drinks, :Beans, :Accounts].each do |table|
    DB.drop_table?(table)
  end
  DB.run("PRAGMA foreign_keys = ON")

  # 2. Re-create the schema
  create_tables
  
  # 3. Insert global seeds
  seed_data
end

def log_in_as(email, password)
  visit '/log-in'
  fill_in 'email', with: email
  fill_in 'password', with: password
  click_button 'Log In'
end

def create_tables
  DB.create_table :Accounts do
    Integer :UserID, primary_key: true
    String :first_name
    String :last_name
    Integer :StampCount, default: 0
    String :email, unique: true, null: false
    String :hashed_password, null: false
    String :PhoneNumber, size: 11
    String :Postcode, size: 7
    String :Address
    String :AccountType, default: 'customer'
    DateTime :Created_At, default: Sequel::CURRENT_TIMESTAMP
    DateTime :Recent_Login, default: Sequel::CURRENT_TIMESTAMP
    TrueClass :Flagged, default: false
    DateTime :Flagged_At
    TrueClass :Suspended, default: false
  end

  DB.create_table :Beans do
    Integer :BeanID, primary_key: true
    String :Name; String :Type; String :Roast; Integer :PackWeight
    Double :Price; Integer :CurrentStock
  end 

  DB.create_table :Drinks do
    Integer :DrinkID, primary_key: true
    String :Beverage; Double :Price; String :Description
  end

  DB.create_table :Orders do
    primary_key :OrderID
    foreign_key :UserID, :Accounts, on_delete: :cascade
    String :OrderContents; String :OrderType; String :PaymentMethod
    Float :totalCost; DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
    String :Location, default: 'In-Store'; TrueClass :IsDelivered, default: false
    TrueClass :IsCompleted, default: false; String :payment_status, default: 'Pending'
  end

  DB.create_table :Tickets do
    primary_key :ticketID
    foreign_key :UserID, :Accounts, on_delete: :cascade
    String :TicketType; String :TicketContent
    FalseClass :TicketResolved, default: false
    DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  end

  DB.create_table :Audits do
    primary_key :AuditID
    foreign_key :orderID, :Orders, on_delete: :cascade
    String :BeforeStatus; String :AfterStatus; Text :ChangeReason
    DateTime :CreatedAt, default: Sequel::CURRENT_TIMESTAMP
  end
end

def seed_data
  # Use cost: 4 for speed in tests
  pass = BCrypt::Password.create('_p_', cost: 4)

  # 1. Accounts
  DB[:Accounts].insert(
    UserID: 10000001,
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com',
    hashed_password: pass,
    PhoneNumber: '07123456789',
    Postcode: 'SW1A1AA',
    Address: '10 Ruby Lane',
    AccountType: 'customer'
  )

  DB[:Accounts].insert(
    UserID: 99999999,
    first_name: 'Admin',
    last_name: 'User',
    email: 'admin@coffee.com',
    hashed_password: pass,
    AccountType: 'administrator'
  )

  DB[:Accounts].insert(
    UserID: 12345678,
    first_name: 'Barista',
    last_name: 'Example',
    email: 'barista@coffee.com',
    hashed_password: pass,
    AccountType: 'barista'
  )

  DB[:Accounts].insert(
    UserID: 23456789,
    first_name: 'Manager',
    last_name: 'Example',
    email: 'manager@coffee.com',
    hashed_password: pass,
    AccountType: 'manager'
  )

  # 2. Beans
  DB[:Beans].insert(
    BeanID: 1,
    Name: 'Ethiopian Yirgacheffe',
    Type: 'Arabica',
    Roast: 'Light',
    PackWeight: 250,
    Price: 8.50,
    CurrentStock: 50
  )

  # 3. Drinks
  DB[:Drinks].insert(
    DrinkID: 1,
    Beverage: 'Flat White',
    Price: 3.50,
    Description: 'Smooth double shot'
  )

  # 4. Orders (Capturing ID for Audits)
  order_items = [{ item: "Flat White", qty: 2, price: 7.00 }].to_json
  order_id = DB[:Orders].insert(
    UserID: 10000001,
    OrderContents: order_items,
    OrderType: 'In-Store',
    totalCost: 7.00,
    payment_status: 'Paid',
    IsCompleted: true,
    CreatedAt: Time.now - 86400 # 1 day ago
  )

  # 5. Tickets
  DB[:Tickets].insert(
    UserID: 10000001,
    TicketType: 'Support',
    TicketContent: 'Loyalty points not showing',
    TicketResolved: false,
    CreatedAt: Time.now
  )

  # 6. Audits
  DB[:Audits].insert(
    orderID: order_id,
    BeforeStatus: 'Pending',
    AfterStatus: 'Paid',
    ChangeReason: 'Customer paid via Card',
    CreatedAt: Time.now
  )

  DB[:Accounts].insert(
    email: 'test@bbc.com',
    hashed_password: BCrypt::Password.create('password123'),
    first_name: 'Test'
  )
  
  DB[:Accounts].insert(
    email: 'suspended@bbc.com',
    hashed_password: BCrypt::Password.create('suspended123'),
    first_name: 'Sussy',
    Suspended: true
  )

    # --- NEW: Uncompleted Orders for Barista Printing ---
  
  # Pending Order 1 (In-Store)
  DB[:Orders].insert(
    UserID: 10000001,
    OrderContents: [{ item: "Latte", qty: 1, price: 3.50 }].to_json,
    OrderType: 'In-Store',
    totalCost: 3.50,
    payment_status: 'Paid',
    IsCompleted: false, # This makes it show up in 'print-order-label'
    CreatedAt: Time.now
  )

  # Pending Order 2 (Online/Delivery)
  DB[:Orders].insert(
    UserID: 10000001,
    OrderContents: [{ item: "Ethiopian Yirgacheffe", qty: 1, price: 8.50 }].to_json,
    OrderType: 'Delivery',
    totalCost: 8.50,
    payment_status: 'Paid',
    IsCompleted: false,
    Location: 'Online',
    CreatedAt: Time.now
  )
end
