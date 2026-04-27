require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'

# Connect to the database
DB = Sequel.sqlite("db/db.sqlite3")

# Clear existing data in correct order to respect foreign keys
[:Tickets, :Orders, :Beans, :Drinks, :Accounts].each do |table| 
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
    AccountType: role
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
    AccountType: "customer"
  )
end

finn_password = BCrypt::Password.create("testpassword?!")

DB[:Accounts].insert(
  UserID: 23242526,
  FirstName: "Finn",
  LastName: "Elliott",
  StampCount: 3,
  email: "finn@mail.com",
  hashedPassword: finn_password,
  PhoneNumber: "07395456262",
  Postcode: "S10 3AJ",
  Address: "58 Endcliffe Vale Road",
  AccountType: "administrator"
)

taha_password = BCrypt::Password.create("Tahatest1234")

DB[:Accounts].insert(
  UserID: 38452738,
  FirstName: "Taha",
  LastName: "Hassanein",
  StampCount: 5,
  email: "taha@gmail.com",
  hashedPassword: taha_password,
  PhoneNumber: "07536476923",
  Postcode: "S10 3AJ",
  Address: "58 Endcliffe Vale Road",
  AccountType: "administrator"
)

# --- BEANS ---
# bean = [ID, Name, Type, Roast, Wight, Price, Stock]
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
  [1, "Latte", 4.40, ""],
  [2, "Americano", 3.80, ""], 
  [3, "Cappuccino", 4.40, ""], 
  [4, "Flat white", 4.35, ""],
  [5, "Cortado", 3.70, ""]
]

puts "Seeding Drinks..."
drinks_list.each do |drink|
  DB[:Drinks].insert(
    DrinkID: drink[0],
    Beverage: drink[1],
    Price: drink[2],
    Description: drink[3]
  )
end
# --- ---

# --- HELPERS ---
MENU_ITEMS = ["Flat White", "Latte", "Cappuccino", "Americano", "Croissant", "Muffin", "Lemon Cake"]
bean_types = DB[:Beans].map(:Type)

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
customer_ids = DB[:Accounts].where(AccountType: "customer").map(:UserID)

40.times do |i|
  # First 5 orders are "Recent/Live" (Incomplete/Unpaid), the rest are historical
  is_past = i > 5 
  
  order_type = ["In-Person", "Delivery"].sample
  
  # Logic for payment status based on whether it's a past order or new
  if is_past
    pay_status = "Paid"
  else
    # Current orders might be unpaid or "Pay in store" for in-person orders
    pay_status = (order_type == "In-Person") ? ["Unpaid", "Pay in store"].sample : "Unpaid"
  end

  DB[:Orders].insert(
    UserID: customer_ids.sample,
    OrderContents: generate_json_contents(bean_types),
    OrderType: order_type,
    PaymentMethod: ["Card", "Cash", "Apple Pay"].sample,
    totalCost: rand(3.50..22.00).round(2),
    CreatedAt: is_past ? days_ago(rand(1..30)) : Time.now,
    Location: order_type == "Delivery" ? "Delivery" : "Table #{rand(1..8)}",
    IsDelivered: is_past,
    IsCompleted: is_past,
    payment_status: pay_status # Added this line
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
    TicketType: ["Complaint", "Technical", "Query"].sample,
    TicketContent: complaint_samples.sample,
    TicketResolved: [true, false].sample
  )
end

# --- 6. AUDITS ---

10.times do
  order_id = DB[:Orders].select(:OrderID).order(Sequel.lit('RANDOM()')).first[:OrderID]
  DB[:Audits].insert(
    orderID: order_id,
    BeforeStatus: ["Pending", "Paid", "Unpaid"].sample,
    AfterStatus: ["Pending", "Paid", "Unpaid"].sample,
    ChangeReason: ["Customer requested change", "Payment issue", "Admin correction"].sample
  )
end

puts "Seed complete: 6 tables populated (Accounts, Beans, Drinks, Orders, Tickets, Audits)."
