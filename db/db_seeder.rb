# Seed data loader for initial application database population.

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

    test_password_hash = BCrypt::Password.create("testpass")

    db_connection[:Accounts].insert(
      user_id: 1,
      first_name: "Customer",
      last_name: "Test",
      stamp_count: 4,
      email: "testcust",
      hashed_password: BCrypt::Password.create("testcust"),
      phone_number: "07395456261",
      postcode: "S3 6RL",
      address: "1 Street Road, Sheffield",
      account_type: "customer"
    )

    db_connection[:Accounts].insert(
      user_id: 11,
      first_name: "toBeFlagged",
      last_name: "Customer",
      stamp_count: 50000,
      email: "testflag@bbc.com",
      hashed_password: test_password_hash,
      phone_number: "07395456261",
      postcode: "S3 6RL",
      address: "1 Street Road, Sheffield",
      account_type: "customer",
      recent_login: Time.now - (31 * 24 * 60 * 60)
    )

    db_connection[:Accounts].insert(
      user_id: 2,
      first_name: "Barista",
      last_name: "Test",
      stamp_count: 0,
      email: "testbarista",
      hashed_password: BCrypt::Password.create("testbarista"),
      phone_number: "07526472935",
      postcode: "S10 3AJ",
      address: "3 Barista Street, Sheffield",
      account_type: "barista"
    )

    db_connection[:Accounts].insert(
      user_id: 3,
      first_name: "Manager",
      last_name: "Test",
      stamp_count: 0,
      email: "testmanager",
      hashed_password: BCrypt::Password.create("testmanager"),
      phone_number: "07738456253",
      postcode: "S3 JS6",
      address: "5 Manager Street, Sheffield",
      account_type: "manager"
    )

    db_connection[:Accounts].insert(
      user_id: 4,
      first_name: "Admin",
      last_name: "Test",
      stamp_count: 0,
      email: "testadmin",
      hashed_password: BCrypt::Password.create("testadmin"),
      phone_number: "07027662738",
      postcode: "S11 32P",
      address: "21 Admin Street, Sheffield",
      account_type: "administrator"
    )

    db_connection[:Accounts].insert(
      user_id: 5,
      first_name: "Sussy",
      last_name: "Acca",
      stamp_count: 52,
      email: "testsuspended@bbc.com",
      hashed_password: test_password_hash,
      phone_number: "07638992635",
      postcode: "S12 PL3",
      address: "21 Suspended Street, Sheffield",
      account_type: "customer",
      suspended: true
    )

    db_connection[:Accounts].insert(
      user_id: 8,
      first_name: "Flaggy",
      last_name: "Boy",
      stamp_count: 52,
      email: "testflagged@bbc.com",
      hashed_password: test_password_hash,
      phone_number: "07027536552",
      postcode: "S13 HS9",
      address: "67 Flagdown Street, Sheffield",
      account_type: "customer",
      flagged: true
    )

    # Random Customers
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

    # Specific Developer Accounts
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
      ["Ethiopian",   150.0, 8.20],
      ["Brazillian",  150.0, 6.35],
      ["Arabic",      200.0, 4.75]
    ]

    bean_list.each do |origin, mass, price|
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
    beans_pack_weight_price_markup_multipliers.each do |weight, markup_multiplier|
      db_connection[:BeansPackWeightPriceMarkupMultipliers].insert(
        pack_weight: weight,
        markup_multiplier: markup_multiplier
      )
    end
    puts "Done"

    puts "Seeding roasts..."
    bean_roasts = ["Light", "Medium", "Dark"]
    bean_roasts.each do |roast|
      db_connection[:BeanRoastLevels].insert(roast_level: roast)
    end
    puts "Done"

    puts "Seeding drinks..."
    drinks = [
      ["Latte",      4.40, true,   "Smooth espresso with steamed milk"],
      ["Americano",  3.80, false,  "A rich, double-shot of espresso diluted with hot water for a bold finish."], 
      ["Cappuccino", 4.40, true,   "Equal parts espresso, steamed milk, and a thick layer of silky foam."], 
      ["Flat white", 4.35, true,   "Velvety micro-foam poured over a double-shot of ristretto."],
      ["Cortado",    3.70, true,   "A perfectly balanced 1:1 ratio of espresso and warm milk."]
    ]

    drinks.each do |bev, price, contains_milk, description|
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
    drink_size_price_markup_mutlipliers.each do |size, markup_multiplier| 
      db_connection[:DrinkSizePriceMarkupMultipliers].insert(
        drink_size: size,
        markup_multiplier: markup_multiplier
      )
    end
    puts "Done"

    puts "Seeding milkTypes table..."
    milk_types_data = [
      ["Whole", 0.1],
      ["Oat",   0.3],
      ["Soy",   0.2]
    ]
    milk_types_data.each do |type, price|
      db_connection[:MilkTypes].insert(
        milk_type: type, 
        price: price
      )
    end
    puts "Done"


    puts "Seeding orders and orderItems tables with extensive history..."
    
    drinks_map   = db_connection[:Drinks].to_hash(:beverage, :regular_price)
    sizes_map    = db_connection[:DrinkSizePriceMarkupMultipliers].to_hash(:drink_size, :markup_multiplier)
    milks_map    = db_connection[:MilkTypes].to_hash(:milk_type, :price)
    beans_map    = db_connection[:Beans].to_hash(:origin, :price_per_250g)
    packs_map    = db_connection[:BeansPackWeightPriceMarkupMultipliers].to_hash(:pack_weight, :markup_multiplier)

    customer_ids = db_connection[:Accounts].where(account_type: "customer").map(:user_id)
    drink_names  = drinks_map.keys
    bean_origins = beans_map.keys
    milk_options = milks_map.keys
    roast_opts   = db_connection[:BeanRoastLevels].map(:roast_level)
    pack_weights = [250.0, 500.0, 1000.0]

    stock_deductions = Hash.new(0.0)

    20.times do |i|
      user_id = customer_ids.sample
      days_ago = rand(0..30)
      hours_ago = rand(1..23)
      created_time = Time.now - (days_ago * 86400) - (hours_ago * 3600)

      is_delivery = [true, false].sample
      address     = is_delivery ? "#{rand(1..120)} Delivery Lane, Sheffield" : "221b Baker St"
      postcode    = is_delivery ? "S#{rand(1..11)} #{rand(1..9)}XX" : "NW1 6XE"
      
      payment_done = days_ago > 2 ? [true, true, false].sample : [true, false].sample
      order_done   = days_ago > 1 ? payment_done : false

      order_id = db_connection[:Orders].insert(
        user_id: user_id,
        created_at: created_time,
        address: address,
        postcode: postcode,
        total_cost: 0.0,
        payment_is_completed: payment_done,
        order_is_completed: order_done
      )

      order_total = 0.0
      items_count = rand(1..3)
      
      order_items_buffer = {}

      items_count.times do
        product_type = ["drink", "bean"].sample
        quantity     = rand(1..2)

        if product_type == "drink"
          item_id    = drink_names.sample
          drink_size = ["Regular", "Large"].sample
          milk       = milk_options.sample
          
          base_price = drinks_map[item_id] || 4.00
          size_mult  = sizes_map[drink_size] || 1.0
          milk_add   = milks_map[milk] || 0.0
          item_cost  = ((base_price * size_mult) + milk_add) * quantity
          
          if order_items_buffer[item_id]
            order_items_buffer[item_id][:quantity] += quantity
            order_items_buffer[item_id][:calculated_cost] += item_cost
          else
            order_items_buffer[item_id] = {
              product_type: "drink",
              quantity: quantity,
              milk_type: milk,
              drink_size: drink_size,
              pack_weight: nil,
              roast_level: nil,
              calculated_cost: item_cost
            }
          end
        else
          item_id     = bean_origins.sample
          pack_weight = pack_weights.sample
          roast       = roast_opts.sample
          
          base_price_250 = beans_map[item_id] || 5.00
          weight_mult    = packs_map[pack_weight] || 1.0
          item_cost      = (base_price_250 * weight_mult) * quantity
          
          stock_deductions[item_id] += (pack_weight / 1000.0) * quantity

          if order_items_buffer[item_id]
            order_items_buffer[item_id][:quantity] += quantity
            order_items_buffer[item_id][:calculated_cost] += item_cost
          else
            order_items_buffer[item_id] = {
              product_type: "bean",
              quantity: quantity,
              milk_type: nil,
              drink_size: nil,
              pack_weight: pack_weight,
              roast_level: roast,
              calculated_cost: item_cost
            }
          end
        end
      end

      order_items_buffer.each do |item_id, details|
        db_connection[:OrderItems].insert(
          order_id: order_id,
          item_id: item_id,
          product_type: details[:product_type],
          quantity: details[:quantity],
          milk_type: details[:milk_type],
          drink_size: details[:drink_size],
          pack_weight: details[:pack_weight],
          roast_level: details[:roast_level]
        )
        order_total += details[:calculated_cost]
      end

      db_connection[:Orders].where(order_id: order_id).update(total_cost: order_total.round(2))
    end

    stock_deductions.each do |origin, kg_bought|
      db_connection[:Beans].where(origin: origin).update(
        stock_mass: Sequel[:stock_mass] - kg_bought
      )
    end
    puts "Done"


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

    puts "Seeding audits table..."
    30.times do
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
    puts "Done"

    puts "Seeding discounts table..."
    db_connection[:Discounts].insert(discount_name: "discount1", discount_multiplier: 0.9)
    db_connection[:Discounts].insert(discount_name: "discount2", discount_multiplier: 0.8)
    db_connection[:Discounts].insert(discount_name: "discount3", discount_multiplier: 0.5)
    puts "Done"

    puts "\n#{db_connection.tables.count} tables populated:"
    db_connection.tables.each { |table| printf(" [%s] ", table) }
    puts "\n"
  end
end