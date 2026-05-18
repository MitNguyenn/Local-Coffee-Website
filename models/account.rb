require "bcrypt"

class Account < Sequel::Model(:Accounts)
  set_primary_key :user_id

  unrestrict_primary_key

  def validate
    super
    errors.add(:email, "is required") if !email || email.empty?
    errors.add(:account_type, "must be assigned") if !self.account_type || self.account_type.empty?
  end

  def password=(raw_password)
    self.hashed_password = BCrypt::Password.create(raw_password)
  end
end
