require 'sequel'
require 'sqlite3'
require 'bcrypt'

# Connect to the same database file
DB = Sequel.connect("sqlite://db.sqlite3")

#seed order table with some data for the metrics page
DB[:Orders].insert(
  UserID: 1,
  OrderContents: "2x Arabica Espresso",
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 15.50
)

DB[:Orders].insert(
  UserID: 1,
  OrderContents: "1x Arabica Latte",
  Order_Type: "In-store",
  Payment_method: "Cash",
  totalCost: 4.00
)

DB[:Orders].insert(
  UserID: 1,
  OrderContents: "3x Arabica Cappuccino",
  Order_Type: "Online",
  Payment_method: "Card",
  totalCost: 18.00
)

puts "Database seeded successfully with sample orders for metrics page!"