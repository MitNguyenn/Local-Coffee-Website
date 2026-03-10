require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'

# Connect to the database
DB = Sequel.connect("sqlite://db.sqlite3")

# Clear existing data
[:Tickets, :Orders, :Beans, :Accounts].each { |table| DB[table].delete }

password_hash = BCrypt::Password.create("password123")

# --- ACCOUNTS ---
john_loyalty = 10000001
DB[:Accounts].insert(
  UserID: john_loyalty,
  FirstName: "John",
  LastName: "Smith",
  email: "abc123@funtime.org.uk",
  hashedPassword: password_hash,
  PhoneNumber: "12345678901",
  Postcode: "S1 2BC",
  Account_type: "Admin"
)

jane_loyalty = 87654321
DB[:Accounts].insert(
  UserID: jane_loyalty,
  FirstName: "Jane",
  LastName: "Doe",
  email: "jane.doe@example.com",
  hashedPassword: BCrypt::Password.create("securepassword").to_s,
  PhoneNumber: "09876543210",
  Postcode: "S2 3DE",
  Account_type: "Customer"
)

# --- BEANS ---
DB[:Beans].insert(BeanType: "Ethiopian", BeanBlend: "Yirgacheffe", BeanRoast: "Light", Current_stock: 350)
DB[:Beans].insert(BeanType: "Colombian", BeanBlend: "House Blend", BeanRoast: "Medium", Current_stock: 1200)

# --- HELPERS ---
def days_ago(n)
  Time.now - (n * 86400) - (rand(3600..7200)) # Subtracted random seconds for variety
end

MENU_ITEMS = ["Flat White", "Latte", "Cappuccino", "Americano", "Espresso", "Pain au Chocolat", "Croissant", "Lemon Cake", "Blueberry Muffin"]

def random_contents
  items = {}
  rand(1..3).times do
    items[MENU_ITEMS.sample] = rand(1..2)
  end
  items.to_json
end

# --- SEEDING LIVE ORDERS (Today) ---

# John's Live Orders
2.times do |i|
  DB[:Orders].insert(
    UserID: john_loyalty, 
    OrderContents: random_contents,
    OrderType: "In-Store",
    PaymentMethod: ["Cash", "Card"].sample,
    totalCost: rand(4.50..15.00).round(2),
    CreatedAt: Time.now - (i * 1800),
    Location: "Counter",
    IsDelivered: false,
    IsCompleted: false
  )
end

# Jane's Live Orders
DB[:Orders].insert(
  UserID: jane_loyalty, 
  OrderContents: { "Iced Latte" => 1, "Blueberry Muffin" => 1 }.to_json,
  OrderType: "Online",
  PaymentMethod: "Apple Pay",
  totalCost: 7.20,
  CreatedAt: Time.now,
  Location: "Pickup Shelf",
  IsDelivered: false,
  IsCompleted: false
)

# --- SEEDING PAST ORDERS (History) ---

# John's History (15 Orders over last 30 days)
15.times do |i|
  DB[:Orders].insert(
    UserID: john_loyalty, 
    OrderContents: random_contents,
    OrderType: ["Online", "In-Store"].sample,
    PaymentMethod: "Card",
    totalCost: rand(3.00..20.00).round(2),
    CreatedAt: days_ago(i + 1),
    Location: "Delivery",
    IsDelivered: true,
    IsCompleted: true
  )
end

# Jane's History (10 Orders over last 20 days)
10.times do |i|
  DB[:Orders].insert(
    UserID: jane_loyalty, 
    OrderContents: random_contents,
    OrderType: "Online",
    PaymentMethod: "Apple Pay",
    totalCost: rand(5.00..12.00).round(2),
    CreatedAt: days_ago(i + 2),
    Location: "Delivery",
    IsDelivered: true,
    IsCompleted: true
  )
end

# --- TICKETS ---
DB[:Tickets].insert(
  UserID: jane_loyalty, 
  ticketType: "Account",
  ticketContent: "I cannot update my postal address in the settings.",
  ticketResolved: false
)

puts "Database seeded successfully!"