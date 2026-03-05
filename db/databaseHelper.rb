require "bcrypt"

module DatabaseHelper
  def hash_user_password(raw_password)
    return BCrypt::Password.create(raw_password).to_s
  end

  def clear_database
    DB.drop_table?(:user_objects, :bean_instances)
    init_account_table
    init_bean_table
    puts "Database reset"
  end

  def init_account_table
    DB.create_table?(:user_objects) do
      primary_key :id
      String :first_name, null: false
      String :last_name, null: false
      String :email, null: false, unique: true
      String :password_hash, null: false
      String :phone, null: false
      String :address, null: false
      String :account_type, null: false, default: "customer"
    end
    puts "created user_objects table"
  end

  def insert_new_account(user)
    begin
      UserObject.create(
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        password_hash: user.password_hash,
        phone: user.phone,
        address: user.address,
        account_type: user.account_type
      )
      puts "Successfully inserted account for: #{user.email}"
    rescue Sequel::UniqueConstraintViolation => e
      puts "Failed to insert account: #{e.message}"
    end
  end

  def init_bean_table
    DB.create_table?(:bean_instances) do
      primary_key :id
      String :bean_type, null: false
      String :bean_blend, null: false
      String :bean_roast, null: false
      Integer :current_stock, null: false
    end
    puts "created bean_instances table"
  end

  def insert_new_bean(bean_object)
    BEANOBJECT.create(
      bean_type: bean_object.bean_type,
      bean_blend: bean_object.bean_blend,
      bean_roast: bean_object.bean_roast,
      current_stock: bean_object.current_stock
    )
    puts "Successfully inserted bean: #{bean_object.bean_type}"
  end

  def collect_user_data(email)
    UserObject.first(email: email)
  end
end
