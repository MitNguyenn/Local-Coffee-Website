require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'

DB = Sequel.sqlite("db/db.sqlite3")

DB.tables.each do | table |
  DB[table].delete if DB.table_exists?(table)
end

puts "Seeding Accounts table..."
password_hash = BCrypt::Password.create("password123")

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
puts "Done"

puts "Seeding beans..."
bean_list = [
  [2, "Casablanca",   8.20, 15],
  [3, "Nether Edge",  6.35, 10],
  [4, "Damascus",     4.75, 30],
]

bean_list.each do |id, name, price, stock|
  puts "inserting: #{name} #{price} #{stock}"
  DB[:Beans].insert(
    BeanID: id,
    Name: name,
    Price: price,
    CurrentStock: stock
  )
end
puts "Done"

puts "Seeding beans pack prices..."
beans_pack_weight_price_markup_multipliers = [
  [ 250, 1.0], # 100% of the original price
  [ 500, 1.7], # 170% and so on...
  [ 1000, 3.3]
]
beans_pack_weight_price_markup_multipliers.each do | weight, markup_multiplier |
  DB[:BeansPackWeightPriceMarkupMultipliers].insert(
    Weight: weight,
    MarkupMultiplier: markup_multiplier
  )
end
puts "Done"

puts "Seeding roasts..."
bean_roasts = [ "Light", "Medium", "Dark"]

bean_roasts.each do | roast |
  puts "inserting: #{roast}"
  DB[:BeanRoasts].insert(
    Roast: roast
  )
end
puts "Done"

puts "Seeding bean origin..."
bean_origins = ["Arabic", "Brazilian", "Ethiopian"]

bean_origins.each do | origin |
  puts "inserting: #{origin}"
  DB[:BeanOrigins].insert(
    Origin: origin
  )
end
puts "Done"

puts "Seeding drinks..."
drinks = [
  [1, "Latte", 4.40, "Smooth espresso with steamed milk"],
  [2, "Americano", 3.8, "A rich, double-shot of espresso diluted with hot water for a smooth, bold finish."], 
  [3, "Cappuccino", 4.4, "Equal parts espresso, steamed milk, and a thick layer of silky foam, topped with a dusting of cocoa."], 
  [4, "Flat white", 4.35, "Velvety micro-foam poured over a double-shot of ristretto for a creamy yet coffee-forward experience."],
  [5, "Cortado", 3.7, "A perfectly balanced 1:1 ratio of espresso and warm milk to reduce acidity without the volume of a latte."]
]

drinks.each do |id, bev, price, description|
  puts "inserting: #{bev} #{price} #{description}"
  DB[:Drinks].insert(
    DrinkID: id,
    Beverage: bev,
    Price: price,
    Description: description
  )
end
puts "Done"

puts "Seeding drink-size price markup mutlipliers..."
drink_size_price_markup_mutlipliers = [
  ["Regular", 1.0],
  ["Large",   1.2]
]

drink_size_price_markup_mutlipliers.each do | size, markup_multiplier | 
  puts "inserting: #{size} #{markup_multiplier}"
  DB[:DrinkSizePriceMarkupMultipliers].insert(
    Size: size,
    MarkupMultiplier: markup_multiplier
  )
end
puts "Done"

puts "Seeding milkTypes table..."
milk = [
  ["Whole", 0.2],
  ["Oat",   0.3],
  ["Soy",   0.1]
]

milk.each do | type, price |
  puts "inserting: #{type} #{price}"
  DB[:MilkTypes].insert(
    Type: type, 
    Price: price
  )
end
puts "Done"

puts "Seeding orders and orderItems tables..."
order_id_1 = DB[:Orders].insert(
  UserID: 23242526,
  OrderType: "In-Person",
  PaymentMethod: "Card",
  CreatedAt: Time.now,
  Destination: "Table 4",
  IsCompleted: true,
  payment_status: 'Paid',
  TotalCost: 9.28 # (5.28 Large Latte + 4.00 for 250g Casablanca)
)

DB[:OrderItems].insert(
  OrderID: order_id_1,
  ProductID: 1, # Latte
  ProductType: "drink",
  Quantity: 1,
  PriceAtPurchase: 5.40,
  Milk: "Oat",
  Size: "Large"
)

DB[:OrderItems].insert(
  OrderID: order_id_1,
  ProductID: 2, # Casablanca Beans
  ProductType: "bean",
  Quantity: 1,
  PriceAtPurchase: 4.00,
  Milk: nil,
  Size: "250g"
)

order_id_2 = DB[:Orders].insert(
  UserID: 38452738,
  OrderType: "Delivery",
  PaymentMethod: "Apple Pay",
  CreatedAt: Time.now,
  Destination: "58 Endcliffe Vale Road",
  IsCompleted: false,
  payment_status: 'Pending',
  TotalCost: 7.80 # (3.80 Americano + 4.00 Casablanca)
)

DB[:OrderItems].insert(
  OrderID: order_id_2,
  ProductID: 2, # Americano
  ProductType: "drink",
  Quantity: 1,
  PriceAtPurchase: 3.80,
  Milk: "none",
  Size: "Regular"
)

DB[:OrderItems].insert(
  OrderID: order_id_2,
  ProductID: 2, # Casablanca Beans
  ProductType: "bean",
  Quantity: 1,
  PriceAtPurchase: 4.00,
  Milk: nil,
  Size: "250g"
)
puts "Done"

complaint_samples = [
  "My coffee was cold.",
  "The delivery driver couldn't find my flat.",
  "I haven't received my loyalty stamps for my last visit.",
  "The bag of beans I bought had a hole in it.",
  "Payment failed but money left my account."
]

customer_ids = DB[:Accounts].where(AccountType: "customer").map(:UserID)

puts "Seeding tickets table..."
10.times do
  DB[:Tickets].insert(
    UserID: customer_ids.sample,
    TicketType: ["Complaint", "Technical", "Query"].sample,
    TicketContent: complaint_samples.sample,
    TicketResolved: [true, false].sample
  )
end
puts "Done"

10.times do
  order_id = DB[:Orders].select(:OrderID).order(Sequel.lit('RANDOM()')).first[:OrderID]
  DB[:Audits].insert(
    orderID: order_id,
    BeforeStatus: ["Pending", "Paid", "Unpaid"].sample,
    AfterStatus: ["Pending", "Paid", "Unpaid"].sample,
    ChangeReason: ["Customer requested change", "Payment issue", "Admin correction"].sample
  )
end

puts "#{DB.tables.count} tables populated:"
DB.tables.each do | table | 
  printf(" %s ", table)
end
puts "\n"

# def days_ago(n)
#   Time.now - (n * 86400) - rand(3600..7200)
# end

# # Function to generate the JSON string for OrderContents
# def generate_json_contents(beans)
#   order_map = {}
#   # Add 1-3 random menu items
#   rand(1..3).times do
#     order_map[MENU_ITEMS.sample] = rand(1..2)
#   end
#   # 40% chance to include a specific bean variety
#   if rand < 0.4
#     order_map["#{beans.sample} Beans (250g)"] = 1
#   end
#   order_map.to_json
# end

# # --- 4. ORDERS ---

# 40.times do |i|
#   # First 5 orders are "Recent/Live", the rest are historical
#   is_past = i > 5 
  
#   DB[:Orders].insert(
#     UserID: customer_ids.sample,
#     OrderContents: generate_json_contents(bean_types),
#     OrderType: ["In-Person", "Delivery"].sample,
#     PaymentMethod: ["Card", "Cash", "Apple Pay"].sample,
#     totalCost: rand(3.50..22.00).round(2),
#     CreatedAt: is_past ? days_ago(rand(1..30)) : Time.now,
#     Location: ["Counter", "Table #{rand(1..8)}", "Delivery"].sample,
#     IsDelivered: is_past,
#     IsCompleted: is_past
#   )
# end
