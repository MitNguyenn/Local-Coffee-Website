require "bcrypt"

class Account < Sequel::Model(:Accounts)
  # Ensure the primary key matches your PDF
  set_primary_key :UserID

  unrestrict_primary_key

  def validate
    super
    errors.add(:email, "is required") if !email || email.empty?
    errors.add(:AccountType, "must be assigned") if !self.AccountType || self.AccountType.empty?
  end

  # Hashes the password before it hits the .sqlite3 file
  def password=(raw_password)
    self.hashedPassword = BCrypt::Password.create(raw_password)
  end
end
