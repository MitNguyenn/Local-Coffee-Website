require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'

# Connect to the database
DB = Sequel.connect("sqlite://db.sqlite3")

DB[:Tickets].delete
DB[:Orders].delete
DB[:Beans].delete
DB[:Accounts].delete

password_hash = BCrypt::Password.create("password123")

john_loyalty = 10000001
DB[:Accounts].insert(
  UserID: john_loyalty,
  First_Name: "John",
  Last_name: "Smith",
  email: "abc123@funtime.org.uk",
  hashedPassword: password_hash,
  Phone_number: "12345678901",
  Postal_address: "S1 2BC",
  Account_type: "Admin"
)

jane_loyalty = 87654321
DB[:Accounts].insert(
  UserID: jane_loyalty,
  First_Name: "Jane",
  Last_name: "Doe",
  email: "jane.doe@example.com",
  hashedPassword: BCrypt::Password.create("securepassword").to_s,
  Phone_number: "09876543210",
  Postal_address: "S2 3DE",
  Account_type: "Customer"
)

DB[:Beans].insert(Bean_type: "Ethiopian", Bean_blend: "Yirgacheffe", Bean_roast: "Light", Current_stock: 350)
DB[:Beans].insert(Bean_type: "Colombian", Bean_blend: "House Blend", Bean_roast: "Medium", Current_stock: 1200)


def days_ago(n)
  Time.now - (n * 86400)
end

# --- LIVE ORDERS ---

# John's new live order
DB[:Orders].insert(
  UserID: john_loyalty, 
  OrderContents: { "Flat White" => 1, "Pain au Chocolat" => 2 }.to_json,
  Order_Type: "In-Store",
  Payment_method: "Cash",
  totalCost: 8.50,
  created_at: Time.now,
  location: "Counter",
  is_delivered: false,
  is_completed: false
)

# Jane's new live order
DB[:Orders].insert(
  UserID: jane_loyalty, 
  OrderContents: { "Iced Caramel Macchiato" => 1 }.to_json,
  Order_Type: "Online",
  Payment_method: "Apple Pay",
  totalCost: 4.75,
  created_at: Time.now,
  location: "Pickup Shelf",
  is_delivered: false,
  is_completed: false
)

# --- PAST ORDERS ---

# John's past order (3 days ago)
DB[:Orders].insert(
  UserID: john_loyalty, 
  OrderContents: { "Americano" => 1 }.to_json,
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 3.00,
  created_at: days_ago(3),
  location: "Delivery",
  is_delivered: true,
  is_completed: true
)

# Jane's past order (7 days ago)
DB[:Orders].insert(
  UserID: jane_loyalty, 
  OrderContents: { "Cappuccino" => 2, "Lemon Cake" => 1 }.to_json,
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 11.20,
  created_at: days_ago(7),
  location: "Delivery",
  is_delivered: true,
  is_completed: true
)


DB[:Tickets].insert(
  UserID: jane_loyalty, 
  ticketType: "Account",
  ticketContent: "I cannot update my postal address in the settings.",
  ticketResolved: false
)

puts "Database seeded successfully with userID as Primary Keys!"