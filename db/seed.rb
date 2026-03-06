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
DB[:Orders].insert(
  UserID: john_id,
  OrderContents: "2x Arabica Espresso",
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 15.50,
  
  # New Fields
  location: "123 Delivery St, London", # Provide address for 'Online' types
  is_delivered: false,                # Explicitly setting state
  is_completed: false                 # Explicitly setting state
)

DB[:Orders].insert(
  UserID: jane_id,
  OrderContents: "1x Flat White",
  Order_Type: "In-Person",
  Payment_method: "Cash",
  totalCost: 3.50,
  location: "In-Store",  # Consistent with your requirement
  is_delivered: true,    # Typically true immediately for in-person
  is_completed: true
)


# 5. Seed Tickets (Table 4)
DB[:Tickets].insert(
  userID: jane_id,
  ticketType: "Account",
  ticketContent: "I cannot update my postal address in the settings.",
  ticketResolved: false
)

puts "Database seeded successfully with updated table names!"
