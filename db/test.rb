require 'bcrypt'

password = "password123"

hashed_password = BCrypt::Password.create(password)



puts hashed_password

hashedpassword2 = BCrypt::Password.new(password)

puts hashedpassword2