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
    first_name: first,
    last_name: last,
    StampCount: 0,
    email: email,
    hashed_password: password_hash,
    PhoneNumber: "07#{rand(100000000..999999999)}",
    Postcode: "S1 1AA",
    Address: "1 Cafe Lane, Sheffield",
    AccountType: role
  )
end

15.times do |i|
  DB[:Accounts].insert(
    UserID: 200000 + i,
    first_name: ["Liam", "Emma", "Noah", "Olivia", "James"].sample,
    last_name: ["Smith", "Jones", "Brown", "Taylor"].sample,
    StampCount: rand(0..9),
    email: "customer#{i}@example.com",
    hashed_password: password_hash,
    PhoneNumber: "07#{rand(100000000..999999999)}",
    Postcode: "S#{rand(1..10)} 2BB",
    Address: "#{rand(1..100)} Residence Rd, Sheffield",
    AccountType: "customer"
  )
end

finn_password = BCrypt::Password.create("testpassword?!")

DB[:Accounts].insert(
  UserID: 23242526,
  first_name: "Finn",
  last_name: "Elliott",
  StampCount: 3,
  email: "finn@mail.com",
  hashed_password: finn_password,
  PhoneNumber: "07395456262",
  Postcode: "S10 3AJ",
  Address: "58 Endcliffe Vale Road",
  AccountType: "administrator"
)

taha_password = BCrypt::Password.create("Tahatest1234")

DB[:Accounts].insert(
  UserID: 38452738,
  first_name: "Taha",
  last_name: "Hassanein",
  StampCount: 5,
  email: "taha@gmail.com",
  hashed_password: taha_password,
  PhoneNumber: "07536476923",
  Postcode: "S10 3AJ",
  Address: "58 Endcliffe Vale Road",
  AccountType: "administrator"
)
puts "Done"

puts "Seeding beans..."
bean_list = [
  ["Ethiopian",   25.0, 8.20],
  ["Brazillian",  17.0, 6.35],
  ["Arabic",      13.0, 4.75]
]

bean_list.each do |origin, mass, price |
  puts "inserting: #{origin} #{mass} #{price}"
  DB[:Beans].insert(
    Origin: origin,
    StockMass: mass,
    PricePer250g: price
  )
end
puts "Done"

puts "Seeding beans pack prices..."
beans_pack_weight_price_markup_multipliers = [
  [ 250.0,  1.0 ], # 100% of the original price
  [ 500.0,  1.7 ], # 170% and so on...
  [ 1000.0, 3.3 ]
]
beans_pack_weight_price_markup_multipliers.each do | weight, markup_multiplier |
  DB[:BeansPackWeightPriceMarkupMultipliers].insert(
    PackWeight: weight,
    MarkupMultiplier: markup_multiplier
  )
end
puts "Done"

puts "Seeding roasts..."
bean_roasts = [ "Light", "Medium", "Dark"]

bean_roasts.each do | roast |
  puts "inserting: #{roast}"
  DB[:BeanRoastLevels].insert(
    RoastLevel: roast
  )
end
puts "Done"

puts "Seeding drinks..."
drinks = [
  ["Latte",      4.40, true,   "Smooth espresso with steamed milk"],
  ["Americano",  3.8,  false,  "A rich, double-shot of espresso diluted with hot water for a smooth, bold finish."], 
  ["Cappuccino", 4.4,  true,   "Equal parts espresso, steamed milk, and a thick layer of silky foam, topped with a dusting of cocoa."], 
  ["Flat white", 4.35, true,   "Velvety micro-foam poured over a double-shot of ristretto for a creamy yet coffee-forward experience."],
  ["Cortado",    3.7,  true,   "A perfectly balanced 1:1 ratio of espresso and warm milk to reduce acidity without the volume of a latte."]
]

drinks.each do | bev, price, contains_milk, description|
  puts "inserting: #{bev} #{price} #{description}"
  DB[:Drinks].insert(
    Beverage: bev,
    ContainsMilk: contains_milk,
    RegularPrice: price,
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
    DrinkSize: size,
    MarkupMultiplier: markup_multiplier
  )
end
puts "Done"

puts "Seeding milkTypes table..."
milk_types = [
  ["Whole", 0.1], # 10p if drink does NOT contain the milk by default
  ["Oat",   0.3], # 30p
  ["Soy",   0.2]  # 20p
]

milk_types.each do | type, price |
  puts "inserting: #{type} #{price}"
  DB[:MilkTypes].insert(
    MilkType: type, 
    Price: price
  )
end
puts "Done"

puts "Seeding orders and orderItems tables..."
puts "Finn is buying large Latte with oat milk and lightly roasted 250g Arabic beans pack"

puts "Updating beans stock mass"
grams_beans_bought = 250.0
kg_bought = grams_beans_bought / 1000.0
current_mass = DB[:Beans].where(Origin: "Arabic").get(:StockMass)

puts "Current stock mass = #{current_mass}"
DB[:Beans].where(Origin: "Arabic").update(
  StockMass: Sequel[:StockMass] - kg_bought
)
puts "Finn bought #{kg_bought}kg of Arabic beans"
current_mass = DB[:Beans].where(Origin: "Arabic").get(:StockMass)
puts "Current stock mass = #{current_mass}"

order_id_1 = DB[:Orders].insert(
  UserID: 23242526,
  OrderType: "In-Person",
  PaymentMethod: "Card",
  CreatedAt: Time.now,
  Location: "In-Store",
  IsCompleted: true,
  payment_status: 'Paid',
  TotalCost: 10.33 # Large Latte with Oat milk + Light roasted 250g Arabic beans pack = 5.58 + 4.75 = 10.33
)

DB[:OrderItems].insert(
  OrderID: order_id_1,
  ItemID: "Latte", # Latte
  ProductType: "drink",
  Quantity: 1,
  Milk: "Oat",
  Size: "Large"
)

DB[:OrderItems].insert(
  OrderID: order_id_1,
  ItemID: "Arabic",
  ProductType: "bean",
  Quantity: 1,
  PackWeight: 250,
  RoastLevel: "Light"
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
