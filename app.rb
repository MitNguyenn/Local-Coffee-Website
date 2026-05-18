# Sinatra app configuration, route loading, and backup automation.

require "dotenv/load"
require "require_all"
require "sinatra"        # Changed from "sinatra/base" to use classic, top-level DSL
require "rqrcode"
require "fileutils"      # Ensure file operations execute cleanly

# 1. Load data layers, models, and global helpers
require_relative "db/db"
require_all "models"
require_all "helpers"

helpers AppHelpers
enable :sessions
set :session_secret, ENV['SESSION_SECRET']

set :root, File.dirname(__FILE__)
set :views, File.join(settings.root, "views")
set :public_folder, File.join(settings.root, "public")

require_all "controllers"

configure do
  backup_dir = File.expand_path('db/backups', settings.root)
  FileUtils.mkdir_p(backup_dir)

  existing_backups = Dir.glob(File.join(backup_dir, '*.sqlite3')).sort_by { |f| File.mtime(f) }
  
  time_since_last_backup = if existing_backups.any?
    Time.now - File.mtime(existing_backups.last)
  else
    Float::INFINITY 
  end

  one_week_in_seconds = 7 * 24 * 60 * 60

  if time_since_last_backup > one_week_in_seconds
    puts "[Automation] More than a week since last backup. Generating safe snapshot..."
    
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    target_file = File.join(backup_dir, "backup_#{timestamp}.sqlite3")

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