# Helper methods for checking and formatting database health.

require 'fileutils'
module DatabaseStatus
  def list_available_backups
    # Safely resolves '../db/backups' relative to this current script's location
    backup_dir = File.expand_path('../db/backups', __dir__)
    
    # Return empty array early if the folder doesn't exist yet
    return [] unless Dir.exist?(backup_dir)

    # Find all sqlite3 databases in that directory
    Dir.glob(File.join(backup_dir, '*.sqlite3')).map do |file_path|
      {
        filename: File.basename(file_path),
        # Formats creation/modification date into standard YYYY-MM-DD HH:MM:SS
        created_at: File.mtime(file_path).strftime('%Y-%m-%d %H:%M:%S'),
        # Converts the raw file size bytes into clean, readable Kilobytes
        size_kb: (File.size(file_path) / 1024.0).round(2)
      }
    end.sort_by { |backup| backup[:created_at] }.reverse # Places the newest backups at the top
  end
end