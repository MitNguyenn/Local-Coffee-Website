# Helper methods for checking and formatting database health.

require 'fileutils'
module DatabaseStatus
  def list_available_backups
    backup_dir = File.expand_path('../db/backups', __dir__)
    
    return [] unless Dir.exist?(backup_dir)

    Dir.glob(File.join(backup_dir, '*.sqlite3')).map do |file_path|
      {
        filename: File.basename(file_path),
        created_at: File.mtime(file_path).strftime('%Y-%m-%d %H:%M:%S'),
        size_kb: (File.size(file_path) / 1024.0).round(2)
      }
    end.sort_by { |backup| backup[:created_at] }.reverse 
  end
end