require 'bcrypt'

module PasswordCheck
  def hash_password(password)
    hashed_password = BCrypt::Password.create(password).to_s
    return hashed_password
  end
end