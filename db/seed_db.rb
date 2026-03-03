# generated the whole thing with Gemini, sorry guys
# this script can be used to generate a sample database, for testing, for example

require 'sequel'
require 'sqlite3'

# 1. Create/Connect to the database file
DB = Sequel.sqlite('db/db.sqlite3')

# 2. Create the 'beans' table if it doesn't exist
DB.create_table? :beans do
  primary_key :id
  String :name, null: false
  String :origin
  String :roast # e.g., Light, Medium, Dark
  Float :price
  String :description
  Integer :stock_quantity
end

# 3. Clear existing data and add sample "Beans"
DB[:beans].delete
beans_list = DB[:beans]

beans_list.insert(
  name: "Midnight Blend", 
  origin: "Ethiopia", 
  roast: "Dark", 
  price: 12.50, 
  description: "A rich, chocolatey profile with hints of blueberry."
)

beans_list.insert(
  name: "Morning Sun", 
  origin: "Colombia", 
  roast: "Light", 
  price: 14.00, 
  description: "Bright acidity with a crisp citrus finish."
)

beans_list.insert(
  name: "Highland Harvest", 
  origin: "Guatemala", 
  roast: "Medium", 
  price: 11.75, 
  description: "Balanced body with notes of caramel and toasted nuts."
)

puts "Successfully generated db/db.sqlite3 with #{DB[:beans].count} bean varieties!"
