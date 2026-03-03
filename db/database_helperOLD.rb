require "sqlite3"
require "bcrypt"

module DatabaseHelper
  $db = SQLite3::Database.new "db.sqlite3"

  def hash_user_password(raw_password)
    return BCrypt::Password.create(raw_password).to_s
  end

  def clear_database
    $db.close if $db
    db_path = "db.sqlite3"
    File.delete(db_path) if File.exist?(db_path)

    $db = SQLite3::Database.new "db.sqlite3"
    puts "Database reset"
  end

  def init_account_table
    $db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS account (
        userID INTEGER PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        postalAddress TEXT NOT NULL,
        accountType TEXT NOT NULL
      );
    SQL
    puts "created account table"
  end

  def insert_new_account(user)
    sql = <<-SQL
      INSERT INTO account (
        firstName, lastName, email, passwordHash, 
        phoneNumber, postalAddress, accountType
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    SQL

    $db.execute(sql, [
      user.firstName, user.lastName, user.email,
      user.passwordHash, user.phoneNumber, 
      user.postalAddress, user.accountType
    ])
    
    puts "Successfully inserted account for: #{user.email}"
  rescue SQLite3::ConstraintException => e
    puts "Failed to insert account: #{e.message}"
  end

  def init_bean_table
    $db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS bean (
        beanID INTEGER PRIMARY KEY,
        beanType TEXT NOT NULL,
        beanBlend TEXT NOT NULL,
        beanRoast TEXT NOT NULL,
        currentStock INT NOT NULL
      );
    SQL
    puts "created bean table"
  end

  def insert_new_bean(bean_object)
    sql = "INSERT INTO bean (beanType, beanBlend, beanRoast, currentStock) VALUES (?, ?, ?, ?)"
    $db.execute(sql, [bean_object.beanType, bean_object.beanBlend, bean_object.beanRoast, bean_object.currentStock])
    puts "Successfully inserted bean: #{bean_object.beanType}"
  end

  def collect_user_data(email)
    sql = "SELECT * FROM account WHERE email = ?"
    result = $db.execute(sql, [email])
    
    if result.empty?
      return nil
    else
      user_data = result[0]
      return user_data
    end
  end
end
