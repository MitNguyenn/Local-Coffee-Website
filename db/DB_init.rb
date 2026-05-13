require_relative 'db_setup'
require_relative 'db_seeder'
require 'sqlite3'
require 'sequel'

module DatabaseManager
  def self.init_tables(db_connection)
    DatabaseInitializer.create_tables(db_connection)
    DatabaseSeeder.seed_data(db_connection)
    puts "Database environment reset and fully seeded successfully!"
  end
end

if __FILE__ == $0
  db_absolute_path = File.expand_path("../../db/db.sqlite3", __FILE__)

  DB = Sequel.sqlite(db_absolute_path)

  DatabaseManager.init_tables(DB)
end