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
