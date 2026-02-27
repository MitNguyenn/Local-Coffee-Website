require "sqlite3"

# Open a database
$db = SQLite3::Database.new "database.db"

def createTestTable
  rows = $db.execute <<-SQL
    create table IF NOT EXISTS numbers (
      name varchar(30),
      val int
    );
  SQL
  puts "created test table 'numbers'"
end

def deleteTestTable
  del = $db.execute <<-SQL
    drop table IF EXISTS numbers;
  SQL
  puts "deleted table 'numbers'"
end

def insertTestData(insertName, insertVal)
  # Use ? as placeholders to safely pass data
  $db.execute("INSERT INTO numbers (name, val) VALUES (?, ?)", [insertName, insertVal])
  puts "Inserted data: #{insertName} with value #{insertVal}"
end

# test
print "Enter Name: "
tempName = gets.chomp   # .chomp removes the \n
print "Enter number: "
tempAge = gets.chomp.to_i # convert to integer if 'val' is a number column

insertTestData(tempName, tempAge)