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
end

def deleteTestTable
  del = $db.execute <<-SQL
    drop table numbers;
  SQL
end

def insertTestData
  thing = $db.execute <<-SQL
    INSERT INTO numbers (name, val)
    VALUES ("John Snow", 67);
  SQL
end

createTestTable
insertTestData