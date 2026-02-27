require "sqlite3"

# Open a database
$db = SQLite3::Database.new "database.db"

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
