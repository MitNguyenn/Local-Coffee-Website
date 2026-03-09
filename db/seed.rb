require 'sequel'
require 'sqlite3'
require 'bcrypt'

# Connect to the same database file
DB = Sequel.connect("sqlite://db/db.sqlite3")

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
# DB[:Beans].insert(
#   BeanType: "Arabica",
#   BeanBlend: "Espresso",
#   BeanRoast: "Medium-dark",
#   CurrentStock: 500
# )

# seeding beans and coffee drinks
DB[:Drinks].delete
DB[:Beans].delete

puts "Seeding Beans..."

# 3. Seed Beans and capture the IDs
# We use .insert to get the auto-incremented ID back
arabica_id = DB[:Beans].insert(
  Name: "House Arabica",
  Roast: "Medium",
  PricePerBag: 9.50,
  CurrentStock: 50
)

robusta_id = DB[:Beans].insert(
  Name: "Dark Robusta",
  Roast: "Dark",
  PricePerBag: 7.25,
  CurrentStock: 30
)

decaf_id = DB[:Beans].insert(
  Name: "Swiss Water Decaf",
  Roast: "Light",
  PricePerBag: 10.00,
  CurrentStock: 20
)

puts "Seeding Drinks..."

# 4. Seed Drinks using the IDs from above
drinks_data = [
  { BeanID: arabica_id, Beverage: "Americano", Size: "Regular", Price: 3.20 },
  { BeanID: arabica_id, Beverage: "Latte",     Size: "Large",   Price: 3.80 },
  { BeanID: robusta_id, Beverage: "Espresso",  Size: "Single",  Price: 2.50 },
  { BeanID: robusta_id, Beverage: "Flat White",Size: "Regular", Price: 3.40 },
  { BeanID: decaf_id,   Beverage: "Cappuccino",Size: "Regular", Price: 3.60 }
]

drinks_data.each do |drink|
  DB[:Drinks].insert(drink)
end
#

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
