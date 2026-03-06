require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'

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
DB[:Beans].insert(
  Bean_type: "Arabica",
  Bean_blend: "Espresso",
  Bean_roast: "Medium-dark",
  Current_stock: 500
)

# 4. Seed Orders (Table 3)
# Example 1: Simple Hash (Item name => Quantity)
content_1 = { "Arabia" => 1, "Perusian" => 2 }.to_json

# Example 2: Detailed Array (Includes price at time of purchase)
content_2 = [
  { name: "Arabia", qty: 2, price: 5.50 },
  { name: "House Blend", qty: 1, price: 4.00 }
].to_json

DB[:Orders].insert(
  UserID: john_id,
  OrderContents: content_1,
  Order_Type: 'In-Person',
  Payment_method: 'Card',
  totalCost: 15.50
)

DB[:Orders].insert(
  UserID: jane_id,
  OrderContents: content_2,
  Order_Type: 'Delivery',
  Payment_method: 'PayPal',
  totalCost: 15.00,
  location: '123 Coffee Lane'
)

# 5. Seed Tickets (Table 4)
DB[:Tickets].insert(
  userID: jane_id,
  ticketType: "Account",
  ticketContent: "I cannot update my postal address in the settings.",
  ticketResolved: false
)

puts "Database seeded successfully"
