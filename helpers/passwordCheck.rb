# Helper methods for validating passwords and account security.

require 'bcrypt'

module PasswordCheck
  def hash_password(password)
    hashed_password = BCrypt::Password.create(password).to_s
    return hashed_password
  end

  def getPlaintextPassword(hashed_password)
    BCrypt::Password.new(hashed_password)
  end
end