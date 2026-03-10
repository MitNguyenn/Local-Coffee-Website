require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'
# Connect to the same database file
DB = Sequel.connect("sqlite://db.sqlite3")


# Helper to create dates in the past
def days_ago(n)
  Time.now - (n * 86400)
end

# 1. Recent Online Order - John
DB[:Orders].insert(
  UserID: john_id,
  OrderContents: { "Arabica Espresso" => 2, "Vanilla Latte" => 1 }.to_json,
  OrderType: "Online",
  PaymentMethod: "Card",
  totalCost: 15.50,
  CreatedAt: days_ago(1),
  Location: "Delivery",
  IsDelivered: true,
  IsCompleted: true
)

# 2. In-Store Order from last week - Jane
DB[:Orders].insert(
  UserID: jane_id,
  OrderContents: { "Arabica Espresso" => 1 }.to_json,
  OrderType: "In-Person",
  PaymentMethod: "Cash",
  totalCost: 3.50,
  CreatedAt: days_ago(8),
  Location: "In-Store",
  IsDelivered: false,
  IsCompleted: true
)

# 3. Large Order from last month - John
DB[:Orders].insert(
  UserID: john_id,
  OrderContents: { "Ethiopian Yirgacheffe" => 3, "Arabica Espresso" => 1 }.to_json,
  OrderType: "Online",
  PaymentMethod: "PayPal",
  totalCost: 28.00,
  CreatedAt: days_ago(35),
  Location: "Delivery",
  IsDelivered: true,
  IsCompleted: true
)

# 4. Pending Delivery - Jane
DB[:Orders].insert(
  UserID: jane_id,
  OrderContents: { "Colombian Roast" => 2 }.to_json,
  OrderType: "Online",
  PaymentMethod: "Card",
  totalCost: 12.00,
  CreatedAt: Time.now,
  Location: "Delivery",
  IsDelivered: false,
  IsCompleted: false
)

# 5. In-Person Order with multiple items - John
DB[:Orders].insert(
  UserID: john_id,
  OrderContents: { "Colombian Roast" => 1, "Vanilla Latte" => 2 }.to_json,
  OrderType: "In-Person",
  PaymentMethod: "Card",
  totalCost: 14.50,
  CreatedAt: days_ago(3),
  Location: "In-Store",
  IsDelivered: false,
  IsCompleted: true
)

# 6. Order from two months ago - Jane
DB[:Orders].insert(
  UserID: jane_id,
  OrderContents: { "Ethiopian Yirgacheffe" => 1 }.to_json,
  OrderType: "Online",
  PaymentMethod: "Card",
  totalCost: 9.00,
  CreatedAt: days_ago(65),
  Location: "Delivery",
  IsDelivered: true,
  IsCompleted: true
)