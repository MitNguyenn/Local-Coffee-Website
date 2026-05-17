# Administrator dashboard, refund, and ticket management routes.

require 'wicked_pdf'
require 'sqlite3'
require 'fileutils'

WickedPdf.configure do |config|
  config.exe_path = Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')
end

# Securely bind the backup folder directly to the top-level application engine settings
set :backup_dir, File.expand_path('../db/backups', settings.root)

# Target-scoped route filter to ensure only authorized administrators can pass
before [
  '/manage-accounts*', 
  '/edit-account*', 
  '/flagged-accounts*', 
  '/suspend-account*', 
  '/order-management/administrator*', 
  '/employee-accounts*', 
  '/delete-account*', 
  '/database-status*'
] do
  unless session[:user_id] && session[:account_type] == 'administrator'
    redirect '/'
  end
end

get '/manage-accounts' do
  @accounts = DB[:Accounts].all
  erb :account_management
end

get '/edit-account/:id' do
  @account = DB[:Accounts].where(user_id: params[:id]).first
  erb :edit_account
end

get '/flagged-accounts' do
  @flagged_accounts = DB[:Accounts].where(flagged: true).all
  erb :flagged_accounts
end

get '/suspend-account/:id' do
  DB[:Accounts].where(user_id: params[:id]).update(suspended: true)
  redirect '/flagged-accounts'
end

get '/order-management/administrator' do
  # 1. Fetch orders marked as completed in the system
  orders = DB[:Orders]
    .where(order_is_completed: true)
    .order(Sequel.desc(:order_id))
    .all

  # 2. Map orders to include aggregated string summaries of their items
  @completed_orders = orders.map do |order|
    # Query items for this specific order
    items = DB[:OrderItems].where(order_id: order[:order_id]).all
    
    # Format each item into a clean, human-readable string snippet
    item_descriptions = items.map do |item|
      details = []
      details << "#{item[:drink_size]}" if item[:drink_size]
      details << "#{item[:roast_level]} roast" if item[:roast_level]
      details << "w/ #{item[:milk_type]}" if item[:milk_type]
      details << "(#{item[:pack_weight]}g)" if item[:pack_weight]
      
      spec = details.empty? ? "" : " [#{details.join(', ')}]"
      "#{item[:quantity]}x #{item[:product_type]}#{spec}"
    end

    # Attach the built text to match your ERB's order[:OrderContents]
    order[:OrderContents] = item_descriptions.empty? ? "No items" : item_descriptions.join(", ")
    order
  end

  erb :order_correction_administrator
end

get '/employee-accounts' do
  employees = DB[:Accounts].where(account_type: ['barista', 'manager', 'administrator']).all
  @grouped_accounts = employees.group_by { |acc| acc[:account_type] }
  erb :employee_accounts
end

get '/database-status' do
  @live_db_size = File.size(DB.opts[:database]) rescue 0
  @live_db_size_kb = (@live_db_size / 1024.0).round(2)
  @live_db_path = DB.opts[:database]

  @backups = list_available_backups
  erb :database_status
end

post '/edit-account/:id' do
  resetPassword = params[:reset_password] == "on"
  
  DB[:Accounts].where(user_id: params[:id]).update(
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    phone_number: params[:phone_number],
    postcode: params[:postcode],
    account_type: params[:account_type]
  )
  if resetPassword
    DB[:Accounts].where(user_id: params[:id]).update(
      hashed_password: BCrypt::Password.create("password123").to_s
    )
  end
  redirect '/manage-accounts'
end

post '/delete-account/:id' do
  DB[:Accounts].where(user_id: params[:id].to_i).delete
  redirect '/employee-accounts'
end

post '/order-management/administrator' do
  order_id       = params[:order_id].to_i
  new_status_str = params[:payment_status] # "Paid" or "Unpaid"
  reason         = params[:reason_note].to_s.strip

  # Basic validation check
  redirect '/order-management/administrator' if reason.empty?

  # Convert string back to database boolean representation
  new_payment_bool = (new_status_str == 'Paid')

  DB.transaction do
    # 1. Fetch current status for historical audit records
    target_order = DB[:Orders].where(order_id: order_id).first
    if target_order
      old_status_str = target_order[:payment_is_completed] ? 'Paid' : 'Unpaid'

      # 2. Only update and audit if an actual status change occurred
      if target_order[:payment_is_completed] != new_payment_bool
        DB[:Orders].where(order_id: order_id).update(payment_is_completed: new_payment_bool)

        # 3. Log structural footprint into the Audits table
        DB[:Audits].insert(
          order_id:      order_id,
          before_status: old_status_str,
          after_status:  new_status_str,
          change_reason: reason
        )
      end
    end
  end

  # Flash messages could be integrated here before returning
  redirect '/order-management/administrator'
end

post '/database-status/backup' do
  FileUtils.mkdir_p(settings.backup_dir)
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  target_file = File.join(settings.backup_dir, "backup_#{timestamp}.sqlite3")

  DB.pool.hold do |raw_conn|
    destination_db = SQLite3::Database.new(target_file)
    begin
      backup = SQLite3::Backup.new(destination_db, 'main', raw_conn, 'main')
      backup.step(-1)
      backup.finish
    ensure
      destination_db.close if destination_db
    end
  end

  redirect '/database-status'
end

post '/database-status/restore' do
  filename = params[:filename]
  source_file = File.join(settings.backup_dir, filename)

  if File.exist?(source_file)
    source_db = SQLite3::Database.new(source_file)
    begin
      DB.pool.hold do |raw_conn|
        backup = SQLite3::Backup.new(raw_conn, 'main', source_db, 'main')
        backup.step(-1)
        backup.finish
      end
    ensure
      source_db.close if source_db
    end
  end

  redirect '/database-status'
end