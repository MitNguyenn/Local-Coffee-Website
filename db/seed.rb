require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'

# Connect to the database
DB = Sequel.connect("sqlite://db.sqlite3")

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

# 15 Customers
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

# --- 2. BEANS ---
bean_list = [
  ["Ethiopian", "Yirgacheffe", "Light", 350],
  ["Colombian", "House Blend", "Medium", 1200],
  ["Brazilian", "Santos", "Dark", 800],
  ["Guatemalan", "Antigua", "Medium", 450],
  ["Vietnamese", "Robusta", "Dark", 600]
]

bean_list.each do |type, blend, roast, stock|
  DB[:Beans].insert(
    BeanType: type, 
    BeanBlend: blend, 
    BeanRoast: roast, 
    Current_stock: stock
  )
end

# --- 3. HELPERS ---
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
