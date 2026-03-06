require "bcrypt"

class Account < Sequel::Model(:Accounts)
  # Ensure the primary key matches your PDF
  set_primary_key :UserID

  def validate
    super
    errors.add(:email, "is required") if !email || email.empty?
    errors.add(:Account_type, "must be assigned") if !self.Account_type || self.Account_type.empty?
  end

  # Hashes the password before it hits the .sqlite3 file
  def password=(raw_password)
    self.hashedPassword = BCrypt::Password.create(raw_password)
  end
end
