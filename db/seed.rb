require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'

# Connect to the database
DB = Sequel.connect("sqlite://db/db.sqlite3")

# Clear existing data in correct order to respect foreign keys
[:Tickets, :Orders, :Beans, :Accounts].each do |table| 
  DB[table].delete if DB.table_exists?(table)
end

password_hash = BCrypt::Password.create("password123")

# --- 1. ACCOUNTS ---
# Staff Roles: administrator, barista, manager
staff_data = [
  ["John", "Admin", "admin@cafe.com", "administrator"],
  ["Alice", "Barista", "alice@cafe.com", "barista"],
  ["Charlie", "Manager", "manager@cafe.com", "manager"]
]

staff_data.each do |first, last, email, role|
  DB[:Accounts].insert(
    UserID: rand(100000..199999),
    FirstName: first,
    LastName: last,
    StampCount: 0,
    email: email,
    hashedPassword: password_hash,
    PhoneNumber: "07#{rand(100000000..999999999)}",
    Postcode: "S1 1AA",
    Address: "1 Cafe Lane, Sheffield",
    Account_type: role
  )
end

15.times do |i|
  DB[:Accounts].insert(
    UserID: 200000 + i,
    FirstName: ["Liam", "Emma", "Noah", "Olivia", "James"].sample,
    LastName: ["Smith", "Jones", "Brown", "Taylor"].sample,
    StampCount: rand(0..9),
    email: "customer#{i}@example.com",
    hashedPassword: password_hash,
    PhoneNumber: "07#{rand(100000000..999999999)}",
    Postcode: "S#{rand(1..10)} 2BB",
    Address: "#{rand(1..100)} Residence Rd, Sheffield",
    Account_type: "customer"
  )
end

# --- BEANS ---
bean_list = [
  [1, "Ethiopian Breeze", "Yirgacheffe", "Light", 250, 12.50, 20],
  [2, "Arabic Beans", "Mocha", "Medium", 1000, 24.99, 15],
  [3, "Amazonian Night", "Santos", "Dark", 250, 18.00, 10],
  [4, "Maya Sunrise", "Antigua", "Medium", 500, 14.25, 30],
  [5, "Hanoi Fuel", "Robusta", "Dark", 500, 11.00, 50]
]

bean_list.each do |id, name, type, roast, weight, price, stock|
  DB[:Beans].insert(
    BeanID: id,
    Name: name,
    Type: type, 
    Roast: roast, 
    PackWeight: weight,
    Price: price,
    CurrentStock: stock
  )
end
# --- ---

# --- Drinks ---
drinks_list = [
  { BeanID: 1, Beverage: "Filter Coffee", Size: "Regular", Price: 1.90 },
  { BeanID: 1, Beverage: "Cold Brew",     Size: "Regular",   Price: 4.20 },
  { BeanID: 2, Beverage: "Latte",         Size: "Regular", Price: 3.50 },
  { BeanID: 2, Beverage: "Cappuccino",    Size: "Regular",   Price: 3.60 },
  { BeanID: 3, Beverage: "Americano",     Size: "Regular", Price: 3.00 },
  { BeanID: 4, Beverage: "Flat White",    Size: "Regular", Price: 3.35 },
  { BeanID: 5, Beverage: "Espresso",      Size: "Double",  Price: 2.20 },
  { BeanID: 5, Beverage: "Cortado",       Size: "Regular",   Price: 3.10 }
]

puts "Seeding Drinks..."
drinks_list.each do |drink|
  DB[:Drinks].insert(drink)
end
# --- ---

# --- HELPERS ---
MENU_ITEMS = ["Flat White", "Latte", "Cappuccino", "Americano", "Croissant", "Muffin", "Lemon Cake"]
bean_types = DB[:Beans].map(:BeanType)

def days_ago(n)
  Time.now - (n * 86400) - rand(3600..7200)
end

# Function to generate the JSON string for OrderContents
def generate_json_contents(beans)
  order_map = {}
  # Add 1-3 random menu items
  rand(1..3).times do
    order_map[MENU_ITEMS.sample] = rand(1..2)
  end
  # 40% chance to include a specific bean variety
  if rand < 0.4
    order_map["#{beans.sample} Beans (250g)"] = 1
  end
  order_map.to_json
end

# --- 4. ORDERS ---
customer_ids = DB[:Accounts].where(Account_type: "customer").map(:UserID)

40.times do |i|
  # First 5 orders are "Recent/Live", the rest are historical
  is_past = i > 5 
  
  DB[:Orders].insert(
    UserID: customer_ids.sample,
    OrderContents: generate_json_contents(bean_types),
    OrderType: ["In-Person", "Delivery"].sample,
    PaymentMethod: ["Card", "Cash", "Apple Pay"].sample,
    totalCost: rand(3.50..22.00).round(2),
    CreatedAt: is_past ? days_ago(rand(1..30)) : Time.now,
    Location: ["Counter", "Table #{rand(1..8)}", "Delivery"].sample,
    IsDelivered: is_past,
    IsCompleted: is_past
  )
end

# --- 5. TICKETS ---
complaint_samples = [
  "My coffee was cold.",
  "The delivery driver couldn't find my flat.",
  "I haven't received my loyalty stamps for my last visit.",
  "The bag of beans I bought had a hole in it.",
  "Payment failed but money left my account."
]

10.times do
  DB[:Tickets].insert(
    UserID: customer_ids.sample,
    ticketType: ["Complaint", "Technical", "Query"].sample,
    ticketContent: complaint_samples.sample,
    ticketResolved: [true, false].sample
  )
end

puts "Seed complete: 4 tables populated (Accounts, Beans, Orders, Tickets)."
