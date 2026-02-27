require "sqlite3"
#CLASSES
class UserAccount
  # Creates getter methods so you can read these attributes later
  attr_accessor :firstName, :lastName, :email, :passwordHash, :phoneNumber, :postalAddress, :accountType

  def init(firstName, lastName, email, passwordHash, phoneNumber, postalAddress, accountType)
    @firstName     = firstName
    @lastName      = lastName
    @email         = email
    @passwordHash  = passwordHash
    @phoneNumber   = phoneNumber
    @postalAddress = postalAddress
    @accountType   = accountType
  end
end




#DATABASE FUNCTIONS
$db = SQLite3::Database.new "database.db"

def clearDatabase
  $db.close if $db

  dbPath = "database.db"
  File.delete(dbPath) if File.exist?(dbPath)

  $db = SQLite3::Database.new "database.db"
  puts "Database reset"
end


#ACCOUNT TABLE
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

#INPUTS
#
def insertNewAccount(user)
  sql = <<-SQL
    INSERT INTO account (
      firstName, lastName, email, passwordHash, 
      phoneNumber, postalAddress, accountType
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
  SQL

  $db.execute(sql, [
    user.firstName,
    user.lastName,
    user.email,
    user.passwordHash,
    user.phoneNumber,
    user.postalAddress,
    user.accountType
  ])
  
  puts "Successfully inserted account for: #{user.email}"
rescue SQLite3::ConstraintException => e
  puts "Failed to insert account: #{e.message}"
end


#INPUTS
#email as a string and changes as a hash map
def update_user_account(email, changeHash)
  setClause = changeHash.keys.map { |column| "#{column} = ?" }.join(", ")

  values = changeHash.values
  
  values << email

  sql = "UPDATE account SET #{setClause} WHERE email = ?"

  $db.execute(sql, values)
  puts "Updated #{changeHash.keys.join(', ')} for account: #{email}"
rescue SQLite3::SQLException => e
  puts "Update failed: #{e.message}"
end
