require 'sequel'
require 'sqlite3'
require 'bcrypt'

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

DB[:Accounts].insert(
  First_Name: "John",
  Last_name: "Smith",
  email: "abc123@funtime.org.uk",
  hashedPassword: password_hash,
  Phone_number: "12345678901",
  Postal_address: "S1 2BC",
  Account_type: "Admin"
)

# 3. Seed Beans (Table 2)
DB[:Beans].insert(
  Bean_type: "Arabica",
  Bean_blend: "Espresso",
  Bean_roast: "Medium-dark",
  Current_stock: 500
)

# 4. Seed Orders (Table 3)
# We use the ID of the user we just created (likely 1)
DB[:Orders].insert(
  UserID: 1,
  OrderContents: "2x Arabica Espresso",
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 15.50
)

# 5. Seed Tickets (Table 4)
DB[:Tickets].insert(
  userID: 1,
  ticketType: "Account",
  ticketContent: "I cannot update my postal address in the settings.",
  ticketResolved: false
)

puts "Database seeded successfully with updated table names!"
