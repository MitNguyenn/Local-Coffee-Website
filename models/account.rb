require "bcrypt"

class Account < Sequel::Model(:Accounts)
  # Ensure the primary key matches your PDF
  set_primary_key :user_id

  unrestrict_primary_key

  def validate
    super
    errors.add(:email, "is required") if !email || email.empty?
    errors.add(:account_type, "must be assigned") if !self.account_type || self.account_type.empty?
  end

  # Hashes the password before it hits the .sqlite3 file
  def password=(raw_password)
    self.hashed_password = BCrypt::Password.create(raw_password)
  end
end
