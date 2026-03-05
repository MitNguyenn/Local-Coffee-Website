require 'bcrypt'

module passwordCheck
  def password_hash(password)
    hashed_password = BCrypt::Password.create(password).to_s
    return hashed_password
  end
end