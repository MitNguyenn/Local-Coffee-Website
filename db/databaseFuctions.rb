require "sqlite3"
require "bcrypt"

# --- HELPER FUNCTIONS ---

def hashUserPasssword(rawPassword)
  # FIX: Corrected BCrypt syntax (::Password.create) and variable assignment
  return BCrypt::Password.create(rawPassword).to_s
end

# --- CLASSES ---

class USERACCOUNT
  attr_accessor :firstName, :lastName, :email, :passwordHash, :phoneNumber, :postalAddress, :accountType

  def initialize(firstName, lastName, email, password, phoneNumber, postalAddress, accountType)
    @firstName     = firstName
    @lastName      = lastName
    @email         = email
    # FIX: Corrected variable name from 'passsword' to 'password'
    @passwordHash  = hashUserPasssword(password)
    @phoneNumber   = phoneNumber
    @postalAddress = postalAddress
    @accountType   = accountType
  end
end

class BEANINSTANCE
  attr_accessor :beanType, :beanBlend, :beanRoast, :currentStock

  def initialize(btype, bblend, broast, currentStock)
    @beanType     = btype
    @beanBlend    = bblend
    @beanRoast    = broast
    @currentStock = currentStock
  end
end

# --- DATABASE FUNCTIONS ---

$db = SQLite3::Database.new "db.sqlite3"

def clearDatabase
  $db.close if $db
  # FIX: Changed "database.db" to "db.sqlite3" to match the actual file name
  dbPath = "db.sqlite3"
  File.delete(dbPath) if File.exist?(dbPath)

  $db = SQLite3::Database.new "db.sqlite3"
  puts "Database reset"
end

def initAccountTable
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

def insertNewAccount(user)
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

def initBeanTable
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

def insertNewBean(beanObject)
  sql = "INSERT INTO bean (beanType, beanBlend, beanRoast, currentStock) VALUES (?, ?, ?, ?)"
  $db.execute(sql, [beanObject.beanType, beanObject.beanBlend, beanObject.beanRoast, beanObject.currentStock])
  puts "Successfully inserted bean: #{beanObject.beanType}"
end

# --- EXECUTION ---

# Initialize the tables first!
initAccountTable
initBeanTable

acc = USERACCOUNT.new("John", "Doe", "abc@hot.org", "password123", "555-1234", "123 Main St", "customer")
insertNewAccount(acc)

bean = BEANINSTANCE.new("Arabica", "Single Origin", "Medium", 100)
insertNewBean(bean)
