require "dotenv/load"
require "require_all"
require "sinatra/base"
require "rqrcode"

require_relative "db/db"
require_all "models"
require_all "helpers"
require_all "controllers"

class CoffeeApp < Sinatra::Base
  helpers AppHelpers
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  
  set :root, File.dirname(__FILE__)
  set :views, proc { File.join(root, "views") }
  set :public_folder, proc { File.join(root, "public") }

  use AuthController
  use ProductController
  use AccountController
  use BaristaController
  use ManagerController
  use AdminController

  # ==========================================
  # Automated Backup Boot Hook
  # ==========================================
  configure do
    # 1. Resolve paths securely relative to this app layout
    backup_dir = File.expand_path('../db/backups', __dir__)
    FileUtils.mkdir_p(backup_dir)

    # 2. Gather all existing backups and sort by file modification time
    existing_backups = Dir.glob(File.join(backup_dir, '*.sqlite3')).sort_by { |f| File.mtime(f) }
    
    # 3. Calculate time elapsed since the last recorded snapshot
    time_since_last_backup = if existing_backups.any?
      Time.now - File.mtime(existing_backups.last)
    else
      Float::INFINITY # Force trigger a backup if no files exist yet
    end

    # 4. If more than 1 week (604,800 seconds) has elapsed, make a backup
    one_week_in_seconds = 7 * 24 * 60 * 60

    if time_since_last_backup > one_week_in_seconds
      puts "[Automation] More than a week since last backup. Generating safe snapshot..."
      
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      target_file = File.join(backup_dir, "backup_#{timestamp}.sqlite3")

      # Extract the live connection securely from your shared DB instance pool
      DB.pool.hold do |raw_conn|
        destination_db = SQLite3::Database.new(target_file)
        begin
          backup = SQLite3::Backup.new(destination_db, 'main', raw_conn, 'main')
          backup.step(-1)
          backup.finish
          puts "[Automation] Automated weekly backup saved: #{File.basename(target_file)}"
        ensure
          destination_db.close if destination_db
        end
      end
    else
      days_left = ((one_week_in_seconds - time_since_last_backup) / (24 * 60 * 60)).round(1)
      puts "[Automation] Database backup is up to date. Next auto-check in #{days_left} days."
    end
  end
  
  run! if app_file == $0
end