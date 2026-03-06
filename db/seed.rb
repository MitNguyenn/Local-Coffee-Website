require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'
# Connect to the same database file
DB = Sequel.connect("sqlite://db.sqlite3")

# 1. Clear existing data (optional, prevents duplicates if you run it twice)
DB[:Tickets].delete
DB[:Orders].delete
DB[:Beans].delete
DB[:Accounts].delete

# 2. Seed Accounts (Table 1)
# Using BCrypt as per the "Sanitisation" lecture slides
password_hash = BCrypt::Password.create("password123")

john_id = DB[:Accounts].insert(
  First_Name: "John",
  Last_name: "Smith",
  email: "abc123@funtime.org.uk",
  hashedPassword: password_hash,
  Phone_number: "12345678901",
  Postal_address: "S1 2BC",
  Account_type: "Admin"
)

jane_id = DB[:Accounts].insert(
  First_Name: "Jane",
  Last_name: "Doe",
  email: "jane.doe@example.com",
  hashedPassword: BCrypt::Password.create("securepassword").to_s,
  Phone_number: "09876543210",
  Postal_address: "S2 3DE",
  Account_type: "Customer"
)

# 3. Seed Beans (Table 2)
# Light Roast Single Origin
DB[:Beans].insert(
  Bean_type: "Ethiopian",
  Bean_blend: "Yirgacheffe",
  Bean_roast: "Light",
  Current_stock: 350
)

# Medium Roast House Blend
DB[:Beans].insert(
  Bean_type: "Colombian",
  Bean_blend: "House Blend",
  Bean_roast: "Medium",
  Current_stock: 1200
)

# Dark Roast Single Origin
DB[:Beans].insert(
  Bean_type: "Sumatra",
  Bean_blend: "Mandheling",
  Bean_roast: "Dark",
  Current_stock: 200
)

# Medium-Dark South American
DB[:Beans].insert(
  Bean_type: "Brazilian",
  Bean_blend: "Santos",
  Bean_roast: "Medium-dark",
  Current_stock: 800
)

# Specialty Light-Medium
DB[:Beans].insert(
  Bean_type: "Guatemalan",
  Bean_blend: "Antigua",
  Bean_roast: "Light-medium",
  Current_stock: 150
)

# Decaf Option
DB[:Beans].insert(
  Bean_type: "Peruvian",
  Bean_blend: "Swiss Water Decaf",
  Bean_roast: "Medium",
  Current_stock: 400
)

# 4. Seed Orders (Table 3)
# Helper to create dates in the past

# Helper to create dates in the past
def days_ago(n)
  Time.now - (n * 86400)
end

# 1. Recent Online Order - John
DB[:Orders].insert(
  UserID: john_id,
  OrderContents: { "Arabica Espresso" => 2, "Vanilla Latte" => 1 }.to_json,
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 15.50,
  created_at: days_ago(1),
  location: "Delivery",
  is_delivered: true,
  is_completed: true
)

# 2. In-Store Order from last week - Jane
DB[:Orders].insert(
  UserID: jane_id,
  OrderContents: { "Arabica Espresso" => 1 }.to_json,
  Order_Type: "In-Person",
  Payment_method: "Cash",
  totalCost: 3.50,
  created_at: days_ago(8),
  location: "In-Store",
  is_delivered: false,
  is_completed: true
)

# 3. Large Order from last month - John
DB[:Orders].insert(
  UserID: john_id,
  OrderContents: { "Ethiopian Yirgacheffe" => 3, "Arabica Espresso" => 1 }.to_json,
  Order_Type: "Online",
  Payment_method: "PayPal",
  totalCost: 28.00,
  created_at: days_ago(35),
  location: "Delivery",
  is_delivered: true,
  is_completed: true
)

# 4. Pending Delivery - Jane
DB[:Orders].insert(
  UserID: jane_id,
  OrderContents: { "Colombian Roast" => 2 }.to_json,
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 12.00,
  created_at: Time.now,
  location: "Delivery",
  is_delivered: false,
  is_completed: false
)

# 5. In-Person Order with multiple items - John
DB[:Orders].insert(
  UserID: john_id,
  OrderContents: { "Colombian Roast" => 1, "Vanilla Latte" => 2 }.to_json,
  Order_Type: "In-Person",
  Payment_method: "Card",
  totalCost: 14.50,
  created_at: days_ago(3),
  location: "In-Store",
  is_delivered: false,
  is_completed: true
)

# 6. Order from two months ago - Jane
DB[:Orders].insert(
  UserID: jane_id,
  OrderContents: { "Ethiopian Yirgacheffe" => 1 }.to_json,
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 9.00,
  created_at: days_ago(65),
  location: "Delivery",
  is_delivered: true,
  is_completed: true
)

# 5. Seed Tickets (Table 4)
DB[:Tickets].insert(
  userID: jane_id,
  ticketType: "Account",
  ticketContent: "I cannot update my postal address in the settings.",
  ticketResolved: false
)

puts "Database seeded successfully"
