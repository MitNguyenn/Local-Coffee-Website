require 'bcrypt'
require 'json'

def spec_before
  DB.run("PRAGMA foreign_keys = OFF")
  [:Audits, :Tickets, :Orders, :Drinks, :Beans, :Accounts].each do |table|
    DB.drop_table?(table)
  end
  DB.run("PRAGMA foreign_keys = ON")

  create_tables
  
  seed_data
end

def log_in_as(email, password)
  visit '/log-in'
  fill_in 'email', with: email
  fill_in 'password', with: password
  click_button 'Log In'
end

def create_tables
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
end

def seed_data
  pass = BCrypt::Password.create('_p_', cost: 4)

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

  bean_list = [
    ["Ethiopian",   25.0, 8.20],
    ["Brazillian",  17.0, 6.35],
    ["Arabic",      13.0, 4.75]
  ]

  bean_list.each do |origin, mass, price |
    DB[:Beans].insert(
      Origin: origin,
      StockMass: mass,
      PricePer250g: price
    )
  end

  beans_pack_weight_price_markup_multipliers = [
    [ 250.0,  1.0 ], # 100% of the original price
    [ 500.0,  1.7 ], # 170% and so on...
    [ 1000.0, 3.3 ]
  ]
  beans_pack_weight_price_markup_multipliers.each do | weight, markup_multiplier |
    DB[:BeansPackWeightPriceMarkupMultipliers].insert(
      PackWeight: weight,
      MarkupMultiplier: markup_multiplier
    )
  end
  bean_roasts = [ "Light", "Medium", "Dark"]

  bean_roasts.each do | roast |
    DB[:BeanRoastLevels].insert(
      RoastLevel: roast
    )
  end

  drinks = [
    ["Latte",      4.40, true,   "Smooth espresso with steamed milk"],
    ["Americano",  3.8,  false,  "A rich, double-shot of espresso diluted with hot water for a smooth, bold finish."], 
    ["Cappuccino", 4.4,  true,   "Equal parts espresso, steamed milk, and a thick layer of silky foam, topped with a dusting of cocoa."], 
    ["Flat white", 4.35, true,   "Velvety micro-foam poured over a double-shot of ristretto for a creamy yet coffee-forward experience."],
    ["Cortado",    3.7,  true,   "A perfectly balanced 1:1 ratio of espresso and warm milk to reduce acidity without the volume of a latte."]
  ]

  drinks.each do | bev, price, contains_milk, description|
    DB[:Drinks].insert(
      Beverage: bev,
      ContainsMilk: contains_milk,
      RegularPrice: price,
      Description: description
    )
  end
  drink_size_price_markup_mutlipliers = [
    ["Regular", 1.0],
    ["Large",   1.2]
  ]

  drink_size_price_markup_mutlipliers.each do | size, markup_multiplier | 
    DB[:DrinkSizePriceMarkupMultipliers].insert(
      DrinkSize: size,
      MarkupMultiplier: markup_multiplier
    )
  end

  milk_types = [
    ["Whole", 0.1], # 10p if drink does NOT contain the milk by default
    ["Oat",   0.3], # 30p
    ["Soy",   0.2]  # 20p
  ]

  milk_types.each do | type, price |

    DB[:MilkTypes].insert(
      MilkType: type, 
      Price: price
    )
  end


  grams_beans_bought = 250.0
  kg_bought = grams_beans_bought / 1000.0
  current_mass = DB[:Beans].where(Origin: "Arabic").get(:StockMass)

  DB[:Beans].where(Origin: "Arabic").update(
    StockMass: Sequel[:StockMass] - kg_bought
  )

  current_mass = DB[:Beans].where(Origin: "Arabic").get(:StockMass)

  order_id_1 = DB[:Orders].insert(
    UserID: 10000001,
    OrderType: "In-Person",
    PaymentMethod: "Card",
    CreatedAt: Time.now,
    Location: "In-Store",
    IsCompleted: true,
    payment_status: 'Paid',
    TotalCost: 10.33 
  )

  DB[:OrderItems].insert(
    OrderID: order_id_1,
    ItemID: "Latte", 
    ProductType: "drink",
    Quantity: 1,
    Milk: "Oat",
    Size: "Large"
  )

  DB[:OrderItems].insert(
    OrderID: order_id_1,
    ItemID: "Arabic",
    ProductType: "bean",
    Quantity: 1,
    PackWeight: 250,
    RoastLevel: "Light"
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
    orderID: order_id_1,
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

end
