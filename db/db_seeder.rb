require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'date'

module DatabaseSeeder
  def self.seed_data(db_connection)
    db_connection.tables.each do |table|
      db_connection[table].delete if db_connection.table_exists?(table)
    end

    puts "Seeding Accounts table..."
    password_hash = BCrypt::Password.create("password123")

    staff_data = [
      ["John", "Admin", "admin@cafe.com", "administrator"],
      ["Alice", "Barista", "alice@cafe.com", "barista"],
      ["Charlie", "Manager", "manager@cafe.com", "manager"]
    ]

    staff_data.each do |first, last, email, role|
      db_connection[:Accounts].insert(
        user_id: rand(100000..199999),
        first_name: first,
        last_name: last,
        stamp_count: 0,
        email: email,
        hashed_password: password_hash,
        phone_number: "07#{rand(100000000..999999999)}",
        postcode: "S1 1AA",
        address: "1 Cafe Lane, Sheffield",
        account_type: role
      )
    end

    15.times do |i|
      db_connection[:Accounts].insert(
        user_id: 200000 + i,
        first_name: ["Liam", "Emma", "Noah", "Olivia", "James"].sample,
        last_name: ["Smith", "Jones", "Brown", "Taylor"].sample,
        stamp_count: rand(0..9),
        email: "customer#{i}@example.com",
        hashed_password: password_hash,
        phone_number: "07#{rand(100000000..999999999)}",
        postcode: "S#{rand(1..10)} 2BB",
        address: "#{rand(1..100)} Residence Rd, Sheffield",
        account_type: "customer"
      )
    end

    finn_password = BCrypt::Password.create("testpassword?!")
    db_connection[:Accounts].insert(
      user_id: 23242526, 
      first_name: "Finn",
      last_name: "Elliott",
      stamp_count: 3,
      email: "finn@mail.com",
      hashed_password: finn_password,
      phone_number: "07395456262",
      postcode: "S10 3AJ",
      address: "58 Endcliffe Vale Road",
      account_type: "administrator"
    )

    taha_password = BCrypt::Password.create("Tahatest1234")
    db_connection[:Accounts].insert(
      user_id: 38452738,
      first_name: "Taha",
      last_name: "Hassanein",
      stamp_count: 5,
      email: "taha@gmail.com",
      hashed_password: taha_password,
      phone_number: "07536476923",
      postcode: "S10 3AJ",
      address: "58 Endcliffe Vale Road",
      account_type: "administrator"
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
      db_connection[:Beans].insert(
        origin: origin,
        stock_mass: mass,
        price_per_250g: price
      )
    end
    puts "Done"

    puts "Seeding beans pack prices..."
    beans_pack_weight_price_markup_multipliers = [
      [ 250.0,  1.0 ],
      [ 500.0,  1.7 ],
      [ 1000.0, 3.3 ]
    ]
    beans_pack_weight_price_markup_multipliers.each do | weight, markup_multiplier |
      db_connection[:BeansPackWeightPriceMarkupMultipliers].insert(
        pack_weight: weight,
        markup_multiplier: markup_multiplier
      )
    end
    puts "Done"

    puts "Seeding roasts..."
    bean_roasts = [ "Light", "Medium", "Dark"]
    bean_roasts.each do | roast |
      puts "inserting: #{roast}"
      db_connection[:BeanRoastLevels].insert(
        roast_level: roast
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
      db_connection[:Drinks].insert(
        beverage: bev,
        contains_milk: contains_milk,
        regular_price: price,
        description: description
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
      db_connection[:DrinkSizePriceMarkupMultipliers].insert(
        drink_size: size,
        markup_multiplier: markup_multiplier
      )
    end
    puts "Done"

    puts "Seeding milkTypes table..."
    milk_types = [
      ["Whole", 0.1],
      ["Oat",   0.3],
      ["Soy",   0.2]
    ]
    milk_types.each do | type, price |
      puts "inserting: #{type} #{price}"
      db_connection[:MilkTypes].insert(
        milk_type: type, 
        price: price
      )
    end
    puts "Done"

    puts "Seeding orders and orderItems tables..."
    grams_beans_bought = 250.0
    kg_bought = grams_beans_bought / 1000.0
    
    db_connection[:Beans].where(origin: "Arabic").update(
      stock_mass: Sequel[:stock_mass] - kg_bought
    )

    order_id_1 = db_connection[:Orders].insert(
      user_id: 23242526,
      order_type: "In-Person",
      payment_method: "Card",
      created_at: Time.now,
      location: "In-Store",
      is_completed: true,
      payment_status: 'Paid',
      total_cost: 10.33 
    )

    db_connection[:OrderItems].insert(
      order_id: order_id_1,
      item_id: "Latte", 
      product_type: "drink",
      quantity: 1,
      milk_type: "Oat",
      drink_size: "Large"
    )

    db_connection[:OrderItems].insert(
      order_id: order_id_1,
      item_id: "Arabic",
      product_type: "bean",
      quantity: 1,
      pack_weight: 250,
      roast_level: "Light"
    )
    puts "Done"

    order_id_2 = db_connection[:Orders].insert(
      user_id: 23242526,
      order_type: "In-Person",
      payment_method: "Card",
      created_at: Time.now-86400,
      location: "In-Store",
      is_completed: false,
      payment_status: 'Paid',
      total_cost: 10.33 
    )

    db_connection[:OrderItems].insert(
      order_id: order_id_2,
      item_id: "Latte", 
      product_type: "drink",
      quantity: 1,
      milk: "Oat",
      size: "Large"
    )

    db_connection[:OrderItems].insert(
      order_id: order_id_2,
      item_id: "Arabic",
      product_type: "bean",
      quantity: 1,
      pack_weight: 250,
      roast_level: "Light"
    )

    complaint_samples = [
      "My coffee was cold.",
      "The delivery driver couldn't find my flat.",
      "I haven't received my loyalty stamps for my last visit.",
      "The bag of beans I bought had a hole in it.",
      "Payment failed but money left my account."
    ]

    refund_complaints = [
      "I wasn't satisfied with the quality of the beans",
      "I asked for dark roast and recieved light",
      "I ordered 1kg of beans and recieved 500g",
      "I don't like coffee",
      "The packaging was heavily damaged on arrival"
    ]

    customer_ids = db_connection[:Accounts].where(account_type: "customer").map(:user_id)

    puts "Seeding tickets table..."
    20.times do
      db_connection[:Tickets].insert(
        user_id: customer_ids.sample,
        ticket_type: ["Complaint", "Technical", "Query"].sample,
        ticket_content: complaint_samples.sample,
        ticket_resolved: [true, false].sample
      )
    end
    10.times do
      db_connection[:Tickets].insert(
        user_id: customer_ids.sample,
        ticket_type: "Refund",
        ticket_content: refund_complaints.sample,
        ticket_resolved: [true, false].sample
      )
    end
    puts "Done"

    10.times do
      order_row = db_connection[:Orders].select(:order_id).order(Sequel.lit('RANDOM()')).first
      if order_row
        db_connection[:Audits].insert(
          order_id: order_row[:order_id],
          before_status: ["Pending", "Paid", "Unpaid"].sample,
          after_status: ["Pending", "Paid", "Unpaid"].sample,
          change_reason: ["Customer requested change", "Payment issue", "Admin correction"].sample
        )
      end
    end

    # DISCOUNTS
    db_connection[:Discounts].insert(discount_name: "discount1", discount_multiplier: 0.9)
    db_connection[:Discounts].insert(discount_name: "discount2", discount_multiplier: 0.8)
    db_connection[:Discounts].insert(discount_name: "discount3", discount_multiplier: 0.5)

    puts "#{db_connection.tables.count} tables populated:"
    db_connection.tables.each { |table| printf(" %s ", table) }
    puts "\n"
  end
end