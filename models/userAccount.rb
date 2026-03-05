require "bcrypt"

class UserObject < Sequel::Model(:user_objects)
  # Add validation from the slides to handle errors
  def validate
    super
    errors.add(:email, "is required") if !email || email.empty?
  end

  # Processing logic: Hash password before saving
  def password=(raw_password)
    self[:password_hash] = BCrypt::Password.create(raw_password)
  end
end